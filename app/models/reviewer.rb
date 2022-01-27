# frozen_string_literal: true

class Reviewer < ApplicationRecord
  belongs_to :review_rule, optional: true
  belongs_to :pull_request, inverse_of: :reviewers

  STATUS_PENDING_APPROVAL = "pending_approval"
  STATUS_APPROVED = "approved"

  before_validation :default_status

  scope :from_rule, -> { where.not(review_rule_id: nil) }
  scope :pending_review, -> { where(status: STATUS_PENDING_APPROVAL) }
  scope :completed_review, -> { where(status: STATUS_APPROVED) }

  has_paper_trail

  def addendum
    <<~ADDENDUM
      ### #{name_with_code}

      - @#{login}
      #{context}
    ADDENDUM
  end

  def name_with_code
    if review_rule.short_code.present?
      "#{review_rule.name} (#{review_rule.short_code})"
    else
      review_rule.name
    end
  end

  def reassign
    return true unless review_rule

    new_reviewer_login =
      review_rule.choose_reviewer(
        pull_request: pull_request,
        extra_excludes: [login]
      )

    if new_reviewer_login && new_reviewer_login.login != login
      new_reviewer = dup
      new_reviewer.review_rule = review_rule
      new_reviewer.pull_request = pull_request
      new_reviewer.login = new_reviewer_login.login
      destroy
      new_reviewer.save!
    else
      false
    end
  end

  def approve!
    self.status = STATUS_APPROVED
    self.approved_at = Time.now.utc
    save!
  end

  private

  def default_status
    self.status ||= STATUS_PENDING_APPROVAL
  end
end
