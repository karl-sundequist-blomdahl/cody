namespace :cleanup do
  desc "Clean up entries in Sidekiq's DeadSet"
  task :dead_set do
    require "sidekiq/api"

    ds = Sidekiq::DeadSet.new
    ds.clear
  end

  desc "Clean up entries in Sidekiq's RetrySet"
  task :retry_set do
    require "sidekiq/api"

    rs = Sidekiq::RetrySet.new
    rs.clear
  end
end
