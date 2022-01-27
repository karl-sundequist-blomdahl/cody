# frozen_string_literal: true

class Types::QueryType < Types::BaseObject
  description "The query root"

  field :viewer, Types::UserType, null: true,
    description: "The currently authenticated user"

  def viewer
    Current.user
  end

  add_field(GraphQL::Types::Relay::NodeField)
  add_field(GraphQL::Types::Relay::NodesField)
end
