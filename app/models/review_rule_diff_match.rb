# frozen_string_literal: true

class ReviewRuleDiffMatch < ReviewRule
  MAX_RETRIES = 3
  validates :file_match, presence: true

  def file_match_regex
    /#{file_match}/
  end

  def matches?(pull_request_hash)
    retries = 0
    begin
      try_match(pull_request_hash)
    rescue Octokit::NotFound => e
      if retries < MAX_RETRIES
        retries += 1
        Rails.logger.info "Request for files for PR ##{pull_request_hash["number"]} was 404, sleeping and retrying (retries = #{retries})"
        sleep(1)
        retry
      else
        raise e
      end
    end
  end

  def try_match(pull_request_hash)
    files = github_client.pull_request_files(
      pull_request_hash["base"]["repo"]["full_name"],
      pull_request_hash["number"]
    )

    matched = files.select { |file| file.patch =~ file_match_regex }

    self.match_context =
      if matched.any?
        matched.map { |file| "  - #{file.filename}" }.join("\n")
      else
        false
      end
  end
end
