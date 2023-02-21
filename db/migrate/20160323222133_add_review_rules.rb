class AddReviewRules < ActiveRecord::Migration[5.0]
  def change
    create_table :review_rules do |t|
      t.string :name
      t.string :type
      t.string :file_match
      t.string :reviewer

      t.timestamps null: false
    end
  end
end
