class AddRepositoryToReviewRules < ActiveRecord::Migration[5.0]
  def change
    add_column :review_rules, :repository, :string
  end
end
