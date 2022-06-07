Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  post "/graphql", to: "graphql#execute"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post "/webhooks/pull_request" => "webhooks#pull_request"
  post "/webhooks/issue_comment" => "webhooks#issue_comment"
  post "/webhooks/integration" => "webhooks#integration"

  # Mirror GitHub's URL structure for Pull Requests
  # These routes all direct the request to the PullsController so it can start
  # the React app
  get "/repos" => "pulls#index"
  get "/repos/:owner/:repo" => "pulls#index"
  get "/repos/:owner/:repo/pulls" => "pulls#index"
  get "/repos/:owner/:repo/pull/:number" => "pulls#index", :as => :pull
  get "/repos/:owner/:repo/rules" => "pulls#index"
  get "/repos/:owner/:repo/rules/:code" => "pulls#index"

  get "/profile" => "pulls#index"

  get "/assigned" => "pulls#index"

  resource :session, only: %i[new create destroy]

  get "/config/schema" => "config#schema"
  post "/config/validate" => "config#validate"

  get "/auth/:provider/callback" => "sessions#create"

  root "pulls#index"
end
