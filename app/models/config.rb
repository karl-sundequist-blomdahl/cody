# frozen_string_literal: true

class Config
  PATH = ".cody.yml"

  SCHEMA = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    id: "https://codybot.xyz/config/schema",
    type: "object",
    title: "Cody YAML schema",
    description: "JSON Schema describing the Cody YAML config file format",
    default: {},
    properties: {
      minimum_reviewers_required: {
        type: "integer",
        title: "Minimum reviewers required",
        description: "The number of peer reviewers that must be present on the PR",
        default: 0,
        minimum: 0
      },
      rules: {
        type: "array",
        title: "Review Rules",
        description: "List of Review Rule configuration objects",
        items: {
          type: "object",
          required: %w[name short_code reviewer match],
          properties: {
            name: {
              type: "string",
              title: "Review Rule name",
              description: "The Review Rule's name is shown in the PR body"
            },
            short_code: {
              type: "string",
              title: "Review Rule short code",
              description: "The Review Rule's short code is used to identify it in commands"
            },
            reviewer: {
              type: "string",
              title: "Reviewer",
              description: "Either a GitHub user or a GitHub team"
            },
            active: {
              type: "boolean",
              title: "Active",
              description: "Activate or inactivate this rule. Inactive rules are not applied to new incoming PRs.",
              default: true
            },
            match: {
              oneOf: [
                {
                  type: "boolean",
                  title: "Review Rule Always",
                  description: "Always Rules always match"
                },
                {
                  type: "object",
                  title: "Review Rule File Match",
                  description: "File Match Rules match based on the paths of changed files",
                  additionalProperties: false,
                  properties: {
                    path: {
                      oneOf: [
                        {
                          type: "array",
                          items: {
                            type: "string"
                          }
                        },
                        {
                          type: "string"
                        }
                      ]
                    }
                  }
                },
                {
                  type: "object",
                  title: "Review Rule Diff Match",
                  description: "Diff Match Rules match based on patterns in the combined diff",
                  additionalProperties: false,
                  properties: {
                    diff: {
                      oneOf: [
                        {
                          type: "array",
                          items: {
                            type: "string"
                          }
                        },
                        {
                          type: "string"
                        }
                      ]
                    }
                  }
                }
              ]
            }
          }
        }
      }
    }
  }.freeze
  # rubocop:enable Layout/LineLength

  attr_reader :input
  attr_reader :errors

  def initialize(input)
    @input = input.with_indifferent_access
  end

  delegate :[], to: :input

  def valid?
    @errors = JSON::Validator.fully_validate(
      Config::SCHEMA,
      input,
      insert_defaults: true
    )
    @errors.empty?
  end
end
