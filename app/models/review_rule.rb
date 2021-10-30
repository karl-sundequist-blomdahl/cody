# frozen_string_literal: true

class ReviewRule < ApplicationRecord
  GENERATED_REVIEWERS_REGEX = /^\s*#*\s*Generated\s*Reviewers\s*$/

  belongs_to :repository, required: true

  validates :name, presence: true
  validates :reviewer, presence: true
  validates :short_code, presence: true, uniqueness: {scope: :repository_id}

  scope :active, -> { where(active: true) }

  include GithubApi

  attr_accessor :match_context

  def reviewer_human_name
    if reviewer.match?(/^\d+$/)
      team = github_client.team(reviewer)
      "#{team.organization.login}/#{team.slug}"
    else
      reviewer
    end
  end

  # Apply this rule to the given Pull Request.
  #
  # If the rule was not previously applied and the rule matches the PR, a new
  # Reviewer record is created for the PR.
  #
  # @return [void]
  def apply(pr, pull_request_hash)
    if !previously_applied?(pr) && matches?(pull_request_hash)
      add_reviewer(pr)
    end
  end

  # Determine if this rule matches the received Pull Request
  #
  # The #matches? method should generate a string of additional context that
  # will be appended to the Generated Reviewers addendum directly below the
  # name of the reviewer that was added. This should be a Markdown-formatted
  # String. Also note that the addendum is also formatted as Markdown. This
  # means that if you want to have a blank line between the reviewer's name and
  # the start of the context, your context should begin with a newline. By
  # default there is no blank line in order to enable the creation of nested
  # lists underneath the reviewer.
  #
  # @param pull_request_hash [Hash] Hash-like resource representing the PR
  # @return [Boolean] true if the rule matches, false otherwise
  def matches?(*)
    # by default nothing matches
    nil
  end

  # Add the reviewer according to the rule's configuration
  #
  # @param pull_request [PullRequest] the PullRequest object to add reviewers to
  # @return [String] the login of the reviewer that was added
  def add_reviewer(pull_request)
    reviewer_to_add = choose_reviewer(pull_request: pull_request)

    pull_request.reviewers.create!(
      login: reviewer_to_add.login,
      review_rule_id: id,
      context: match_context
    )

    pull_request.save!

    reviewer_to_add.login
  end

  # List the possible reviewers according to this rule's configuration
  #
  # @return [ReviewrList] the list of possible reviewers for this rule
  def possible_reviewers
    if reviewer.include?("/")
      org, team = reviewer.split("/", 2)
      access_token = integration_access_token(
        installation_id: repository.installation.github_id
      )
      context = {access_token: access_token}
      result = Graphql::Github.team_members(
        org: org,
        team: team,
        context: context
      )
      ReviewerList.new(reviewers: result.data.organization.team.members.nodes)
    elsif reviewer.match?(/^\d+$/)
      team_members = github_client.team_members(reviewer)
      ReviewerList.new(reviewers: team_members.map(&:login))
    else
      # it's just a single user
      ReviewerList.new(reviewers: Array(reviewer))
    end
  end

  def possible_reviewer?(login)
    possible_reviewers.find { |r| r.login == login }.present?
  end

  # @return [Boolean] true if the rule was previously applied, false otherwise
  def previously_applied?(pr)
    pr.reviewers.find_by(review_rule_id: id)
  end

  # Encapsulates choosing a reviewer according to this ReviewRule's options,
  # including multiple layers of fallbacks.
  #
  # @param pull_request [PullRequest] the PullRequest object
  # @param extra_excludes [Array<String>] an Array of extra logins to exclude
  #   from the initial search
  # @return [#login]
  def choose_reviewer(pull_request:, extra_excludes: [])
    reviewer_list = possible_reviewers

    commit_authors = pull_request.commit_authors

    excludes =
      pull_request.pending_review_logins |
      commit_authors |
      extra_excludes

    reviewer_list.choose_reviewer(
      exclude_list: excludes
    ) ||
      reviewer_list.choose_reviewer(
        exclude_list: pull_request.pending_review_logins
      ) ||
      reviewer_list.choose_reviewer
  end

  def self.apply(pr, pull_request_hash)
    repo = Repository.find_by_full_name(
      pull_request_hash["base"]["repo"]["full_name"]
    )
    rules = repo.review_rules.active
    return if rules.empty?

    rules.each do |rule|
      rule.apply(pr, pull_request_hash)
    end
  end
end
