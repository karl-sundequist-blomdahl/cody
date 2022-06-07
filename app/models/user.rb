# frozen_string_literal: true

require "jwt"

class User < ApplicationRecord
  validates :login, presence: true
  validates :uid, presence: true

  has_one :user_preference, inverse_of: :user
  has_many :api_keys

  attr_encrypted :access_key, key: :encryption_key

  ALLOWED_JWT_ALGORITHMS = %w[HS256 RS256].freeze

  USER_PREFERENCES = %i[
    send_new_reviews_summary
    send_new_reviews_summary?
    paused
    paused?
  ].freeze

  # rubocop:disable Lint/AmbiguousOperator
  delegate *USER_PREFERENCES, to: :user_preference, allow_nil: true
  # rubocop:enable Lint/AmbiguousOperator

  def timezone
    raw = user_preference&.timezone || Rails.application.config.time_zone
    ActiveSupport::TimeZone[raw]
  end

  def role
    ActiveSupport::StringInquirer.new(super)
  end

  def assigned_reviews(status: nil, review_rule: nil, repository: nil)
    AssignedReviewsQuery.run(login: login, status: status, review_rule_name: review_rule, repository_name: repository)
  end

  def average_review_speed(since:)
    AverageReviewSpeedQuery.new(login: login, since: since).run
  end

  def accessible_installations
    installation_ids = github_client.find_user_installations.installations&.map(&:id)
    Installation.where(github_id: installation_ids)
  end

  def make_api_key
    api_key = api_keys.build
    api_key.password = SecureRandom.base58(24)
    api_key
  end

  def self.from_access_token(access_token)
    return unless access_token
    # First decode the token without verification to get the token's encryption
    # algorithm. The payload is discarded because it can't be trusted.
    _, header = JWT.decode(access_token, nil, false)
    alg = header["alg"]

    # Return unless the token's algorithm is one of the supported algorithms.
    # This prevents attackers from passing a token with algorithm set to "none".
    return unless ALLOWED_JWT_ALGORITHMS.include?(alg)

    # Now extract the payload according to the algorithm. Verification is
    # enabled and verification errors are caught and converted to nil. Assuming
    # verification of the token succeeds, then we can simply lookup the user by
    # the "sub" claim.
    begin
      case alg
      when "HS256"
        # HS256 tokens come from the /token/authenticate route and are used by
        # the React application.
        secret_key = Rails.application.secrets.jwt_secret_key
        payload, _ = JWT.decode(
          access_token,
          secret_key,
          true,
          algorithm: "HS256"
        )
        User.find_by(login: payload["sub"])
      when "RS256"
        # RS256 tokens are used by external clients authenticating with the
        # GraphQL API.
        nil
      end
    rescue JWT::VerificationError
      nil
    end
  end

  def make_access_token
    payload = {
      sub: login,
      iat: Time.now.to_i
    }
    JWT.encode(payload, Rails.application.secrets.jwt_secret_key, "HS256")
  end

  private

  def encryption_key
    base64_key = Rails.application.secrets.attr_encrypted_key
    base64_key.unpack1("m")
  end

  def github_client
    @github_client ||= Octokit::Client.new(access_token: access_key)
  end
end
