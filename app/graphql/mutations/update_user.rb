# frozen_string_literal: true

module Mutations
  class UpdateUser < Mutations::BaseMutation
    description "Update the currently authenticated user"

    argument :email, String, required: true
    argument :timezone, String, required: true

    field :user, Types::UserType, null: true

    def resolve(email:, timezone:)
      current_user = context[:current_user]
      current_user.update!(email: email)

      unless current_user.user_preference.present?
        current_user.build_user_preference
      end

      current_user.user_preference.update!(
        timezone: timezone
      )

      {
        user: current_user
      }
    end
  end
end
