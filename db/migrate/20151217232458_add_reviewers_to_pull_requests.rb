class AddReviewersToPullRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :pull_requests, :pending_reviews, :string
    add_column :pull_requests, :completed_reviews, :string
  end
end
