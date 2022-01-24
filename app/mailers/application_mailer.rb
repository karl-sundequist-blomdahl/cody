# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_FROM_ADDRESS", "no-reply@example.com")
  layout "mailer"
  helper :application

  def default_url_options
    {
      host: ENV["CODY_HOST"]
    }
  end
end
