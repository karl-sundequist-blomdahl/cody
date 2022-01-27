require "json"
require "erb"

module FixtureHelper
  # Parse a JSON fixture, optionally evaluating ERB if the `.erb` extension is
  # used.
  #
  # @param path [String] the name of the fixture file without extensions
  # @param locals [Hash] a Hash of local variables if using ERB
  # @return the result of loading the JSON
  def json_fixture(path, locals = {})
    contents =
      if Rails.root.join("spec", "fixtures", "#{path}.json.erb").exist?
        erb = File.read(Rails.root.join("spec", "fixtures", "#{path}.json.erb"))
        ERB.new(erb).result_with_hash(locals)
      else
        File.open(Rails.root.join("spec", "fixtures", "#{path}.json"))
      end

    JSON.parse(contents)
  end

  # Reads an ERB fixture and returns the result
  #
  # @param path [String] the name of the fixture file without .erb extension
  # @param locals [Hash] a Hash of local variables
  # @return [String] the result of evaluating the ERB
  def erb_fixture(path, locals = {})
    erb = File.read(Rails.root.join("spec", "fixtures", "#{path}.erb"))
    ERB.new(erb).result_with_hash(locals)
  end
end

RSpec.configure do |config|
  config.include FixtureHelper
end
