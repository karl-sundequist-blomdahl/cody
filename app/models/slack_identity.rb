# frozen_string_literal: true

class SlackIdentity < ApplicationRecord
  validates :uid, presence: true, uniqueness: {scope: :slack_team_id}

  belongs_to :user, optional: false
  belongs_to :slack_team, optional: false
end
