# frozen_string_literal: true

require "base64"
require "digest"

class Repository < ApplicationRecord
  include GithubApi

  has_many :pull_requests
  has_many :review_rules

  belongs_to :installation

  attr_reader :config

  def self.find_by_full_name(full_name)
    owner, name = full_name.split("/", 2)
    find_by(owner: owner, name: name)
  end

  def full_name
    "#{owner}/#{name}"
  end

  # Refresh this repository's config by reading the configuration file from
  # GitHub. If the configuration file could not be read, this method exits early
  # and does not update any configuration.
  def refresh_config!
    contents =
      begin
        Base64.decode64(
          github_client.contents(full_name, path: Config::PATH).content
        )
      rescue Octokit::NotFound
        return
      end

    digest = Digest::MD5.new
    digest.update(contents)
    hexdigest = digest.hexdigest
    return unless config_hash != hexdigest

    @config =
      begin
        Config.new(YAML.safe_load(contents))
      rescue Psych::Exception
        return
      end
    return unless config.valid?

    refresh_rules

    self.config_hash = hexdigest
    save!
  end

  private

  def refresh_rules
    teams = github_client.org_teams(owner)
    config[:rules]&.each do |rule_config|
      refresh_rule(rule_config, teams)
    end
  end

  def refresh_rule(rule_config, teams)
    rule =
      if rule_config[:match] == true
        ReviewRuleAlways.find_or_initialize_by(
          short_code: rule_config[:short_code],
          repository_id: id
        )
      elsif rule_config[:match][:path]
        ReviewRuleFileMatch.find_or_initialize_by(
          short_code: rule_config[:short_code],
          repository_id: id
        ).tap do |r|
          r.file_match = Array.wrap(rule_config[:match][:path]).join("|")
        end
      elsif rule_config[:match][:diff]
        ReviewRuleDiffMatch.find_or_initialize_by(
          short_code: rule_config[:short_code],
          repository_id: id
        ).tap do |r|
          r.file_match = Array.wrap(rule_config[:match][:diff]).join("|")
        end
      end

    return unless rule

    rule.reviewer = rule_config[:reviewer]

    rule.name = rule_config[:name]
    rule.active = rule_config[:active]

    rule.save!
  end
end
