source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.3"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "6.1.4.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.3"
# Use SCSS for stylesheets
gem "sass-rails", "~> 6.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 5.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem "jquery-rails"
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem "turbolinks"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.11"
# bundle exec rake doc:rails generates the API under doc/api.
gem "sdoc", "~> 2.3.0", group: :doc

# Use ActiveModel has_secure_password
gem "bcrypt", "~> 3.1.16"

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem "puma"

gem "sidekiq"

gem "octokit"

gem "sentry-ruby"

gem "sentry-rails"

gem "sentry-sidekiq"

gem "haml-rails"

gem "dalli"

gem "faraday"

gem "faraday-http-cache"

gem "omniauth-github"

gem "omniauth-rails_csrf_protection"

gem "jwt"

gem "webpacker"

gem "graphql"

gem "kaminari"

gem "pundit"

gem "paper_trail", "~> 12.1"

group :development, :test do
  gem "break"
  gem "pry-rails"

  gem "rspec-rails"

  gem "dotenv-rails"

  gem "memory_profiler", require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console", "~> 4.2"
  gem "listen", ">= 3.0.5", "< 3.8"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"

  gem "netrc"

  gem "rubocop"
  gem "standard", "~> 1", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false

  gem "letter_opener"

  gem "derailed_benchmarks"
  gem "stackprof"
end

group :test do
  gem "factory_bot_rails"
  gem "shoulda-matchers"
  gem "webmock"
  gem "vcr"

  gem "codecov", require: false

  gem "capybara", "~> 3.36"
  gem "selenium-webdriver"

  gem "timecop"
end

gem "graphiql-rails", group: :development

gem "tzinfo-data"

gem "json-schema"

gem "sidekiq-unique-jobs"

gem "attr_encrypted", "~> 3.1.0"

gem "scout_apm"

gem "barnes"

gem "bootsnap", require: false

gem "rack-canonical-host"

gem "sendgrid-actionmailer"

gem "rack-floc_block", "~> 0.1"

gem "rack-attack"

gem "oj"
