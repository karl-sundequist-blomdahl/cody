# frozen_string_literal: true

class Types::PullRequestType < Types::BaseObject
  implements GraphQL::Types::Relay::Node

  global_id_field :id

  field :number, String, null: false
  field :repository, String, null: false, description: "The full name of the repository, in `owner/name` format"
  field :title, String, null: true
  field :head_sha, String, null: true
  field :html_url, String, null: true

  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  def repository
    @object.repository.full_name
  end
  field :status, String, null: false

  field :reviewers, Types::ReviewerType.connection_type, null: true, connection: true do
    argument :status, Types::ReviewerStatusType, required: false
  end

  def reviewers(**args)
    case args[:status]
    when Reviewer::STATUS_PENDING_APPROVAL
      @object.reviewers.pending_review
    when Reviewer::STATUS_APPROVED
      @object.reviewers.completed_review
    else
      @object.reviewers
    end
  end
end
