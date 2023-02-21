class AddRepositoryToPullRequest < ActiveRecord::Migration[5.0]
  def change
    add_column :pull_requests, :repository, :string
  end
end
