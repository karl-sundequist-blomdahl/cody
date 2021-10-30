# frozen_string_literal: true

module Mutations
  class UpdateUser < Mutations::BaseMutation
    description "Update the currently authenticated user"

    argument :email, String, required: true
    argument :send_new_reviews_summary, Boolean, required: true
    argument :timezone, String, required: true

    field :user, Types::UserType, null: true

    def resolve(email:, send_new_reviews_summary:, timezone:)
      current_user = context[:current_user]
      current_user.update!(email: email)

      unless current_user.user_preference.present?
        current_user.build_user_preference
      end

      current_user.user_preference.update!(
        send_new_reviews_summary: send_new_reviews_summary,
        timezone: timezone
      )

      {
        user: current_user
      }
    end
  end
end
