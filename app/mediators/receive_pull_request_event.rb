# frozen_string_literal: true

class ReceivePullRequestEvent
  include Sidekiq::Worker
  include GithubApi

  def perform(payload)
    Sentry.configure_scope do |scope|
      scope.set_user(username: payload["sender"]["login"])
      scope.set_tags(
        event: "pull_request",
        repo: payload["repository"]["full_name"]
      )

      do_perform(payload)
    end
  end

  def do_perform(payload)
    Current.reset

    @payload = payload

    if (installation_id = @payload.dig("installation", "id"))
      Current.installation_id = installation_id
    end

    # check for ignored labels
    @repository =
      Repository.find_by_full_name(@payload["repository"]["full_name"])

    # Process "closed" action before checking for ignores
    PaperTrail.request(whodunnit: @payload["sender"]["login"]) do
      case @payload["action"]
      when "closed"
        on_closed
        Current.reset
        return
      end
    end

    if @payload["pull_request"]["draft"]
      github_client.create_status(
        @payload["repository"]["full_name"],
        @payload["pull_request"]["head"]["sha"],
        "pending",
        {
          context: "code-review/cody",
          description: PullRequest::STATUS_SKIPPED
        }
      )

      Current.reset
      return
    end

    PaperTrail.request(whodunnit: @payload["sender"]["login"]) do
      case @payload["action"]
      when "opened"
        on_opened
      when "synchronize"
        on_synchronize
      when "closed"
        on_closed
      end
    end

    Current.reset
  end

  def on_opened
    CreateOrUpdatePullRequest.new.perform(@payload["pull_request"])
  end

  def on_closed
    number = @payload["number"]
    if (pr = @repository.pull_requests.find_by(number: number))
      if pr.status == "pending_review"
        pr.status = PullRequest::STATUS_CLOSED
        pr.save!
        pr.update_status("Pull Request closed")
      end
    end
  end

  # The "synchronize" event occurs whenever a new commit is pushed to the branch
  # or the branch is rebased.
  #
  # In this case, we preserve the current review status and update the new
  # commit with the correct status indicator.
  def on_synchronize
    CreateOrUpdatePullRequest.new.perform(@payload["pull_request"])
  end
end
