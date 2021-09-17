# rubocop:disable Naming/VariableName
require "rails_helper"

# mock objects to handle the GraphQL response
class UserWithStatus
  attr_reader :login
  attr_reader :status

  def initialize(login:, indicatesLimitedAvailability:)
    @login = login
    @status = UserStatus.new(indicatesLimitedAvailability: indicatesLimitedAvailability)
  end

  class UserStatus
    attr_reader :indicatesLimitedAvailability

    def initialize(indicatesLimitedAvailability:)
      @indicatesLimitedAvailability = indicatesLimitedAvailability
    end

    def indicates_limited_availability?
      @indicatesLimitedAvailability
    end
  end
end

RSpec.describe ReviewerList do
  describe "#choose_reviewer" do
    it "does not pick users who are in the exclude_list" do
      exclude_list = ["aergonaut"]
      list = ReviewerList.new(reviewers: ["aergonaut", "robertmonahon"])
      chosen_reviewer = list.choose_reviewer(exclude_list: exclude_list)
      expect(chosen_reviewer.login).to eq("robertmonahon")
    end

    it "returns nil when all users are excluded" do
      exclude_list = ["aergonaut", "robertmonahon"]
      list = ReviewerList.new(reviewers: ["aergonaut", "robertmonahon"])
      chosen_reviewer = list.choose_reviewer(exclude_list: exclude_list)
      expect(chosen_reviewer).to be_nil
    end

    it "implicitly excludes users with `indicatesLimitedAvailability`" do
      reviewers =
        [
          UserWithStatus.new(login: "aergonaut", indicatesLimitedAvailability: false),
          UserWithStatus.new(login: "robertmonahon", indicatesLimitedAvailability: true)
        ]

      list = ReviewerList.new(reviewers: reviewers)
      chosen_reviewer = list.choose_reviewer(exclude_list: [])
      expect(chosen_reviewer.login).to eq("aergonaut")
    end
  end
end
# rubocop:enable Naming/VariableName
