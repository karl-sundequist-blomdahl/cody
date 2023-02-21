class CreatePullRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :pull_requests do |t|
      t.string :status
      t.string :number

      t.timestamps null: false
    end
  end
end
