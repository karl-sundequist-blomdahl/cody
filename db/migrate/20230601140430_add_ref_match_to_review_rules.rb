class AddRefMatchToReviewRules < ActiveRecord::Migration[6.1]
  def change
    add_column :review_rules, :ref_match, :string
  end
end
