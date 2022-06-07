class DropSlackTables < ActiveRecord::Migration[6.1]
  def change
    drop_table :slack_identities do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :slack_team, foreign_key: true
      t.string :uid, null: false
      t.string :channel

      t.index [:uid, :slack_team_id], unique: true

      t.timestamps
    end

    drop_table :slack_teams do |t|
      t.string :team_id, null: false
      t.string :name, null: false
      t.string :encrypted_bot_access_token
      t.string :encrypted_bot_access_token_iv

      t.index :team_id, unique: true

      t.timestamps
    end

  end
end
