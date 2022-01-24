require "rails_helper"

RSpec.describe Repository, type: :model do
  it { is_expected.to have_many :pull_requests }
  it { is_expected.to have_many :review_rules }
  it { is_expected.to belong_to :installation }

  describe ".find_by_full_name" do
    let!(:expected) { FactoryBot.create :repository }
    let(:full_name) { "#{expected.owner}/#{expected.name}" }

    subject { Repository.find_by_full_name(full_name) }

    it { is_expected.to eq(expected) }
  end

  describe "#full_name" do
    let(:repo) { FactoryBot.build :repository }
    let(:full_name) { "#{repo.owner}/#{repo.name}" }

    subject { repo.full_name }

    it { is_expected.to eq(full_name) }
  end

  describe "#refresh_config!" do
    let!(:repo) { FactoryBot.create :repository }
    let(:sample_config) do
      erb_fixture(
        "sample_config.yml",
        existing_rule: existing_rule,
        deactivated_rule: deactivated_rule
      )
    end
    let(:api_contents) do
      json_fixture(
        "contents",
        path: ".cody.yml",
        name: ".cody.yml",
        encoded_content: Base64.urlsafe_encode64(sample_config)
      )
    end

    let!(:existing_rule) { FactoryBot.create :review_rule_always, repository: repo, reviewer: 1234 }
    let!(:deactivated_rule) { FactoryBot.create :review_rule_always, repository: repo, reviewer: 2345 }

    let(:teams) do
      [
        {
          id: 1,
          name: "Second Level",
          slug: "second-level"
        },
        {
          id: 2,
          name: "Migrations",
          slug: "migrations-reviewers"
        },
        {
          id: 1234,
          name: "Existing Rule",
          slug: "existing-rule"
        },
        {
          id: 2345,
          name: "Deactivated Rule",
          slug: "deactivated-rule"
        }
      ]
    end

    before do
      stub_request(:get, "https://api.github.com/repos/#{repo.full_name}/contents/.cody.yml")
        .to_return(
          status: 200,
          headers: {"Content-Type" => "application/json"},
          body: JSON.dump(api_contents)
        )

      stub_request(:get, "https://api.github.com/orgs/#{repo.owner}/teams")
        .to_return(
          status: 200,
          headers: {"Content-Type" => "application/json"},
          body: JSON.dump(json_fixture("list_teams", teams: teams))
        )
    end

    it "applies the config according to the file", :aggregate_failures do
      repo.refresh_config!
      repo.reload

      second_level = repo.review_rules.find_by(short_code: "second_level")
      expect(second_level).to be_present
      expect(second_level).to be_a(ReviewRuleAlways)
      expect(second_level.reviewer).to eq("testorg/second-level")

      migrations = repo.review_rules.find_by(short_code: "migrations")
      expect(migrations).to be_present
      expect(migrations).to be_a(ReviewRuleFileMatch)
      expect(migrations.reviewer).to eq("testorg/migrations-reviewers")

      octocat = repo.review_rules.find_by(short_code: "octocat")
      expect(octocat).to be_present
      expect(octocat).to be_a(ReviewRuleDiffMatch)
      expect(octocat.reviewer).to eq("octocat")

      old_name = existing_rule.name
      existing_rule.reload
      expect(existing_rule.name).to eq("#{old_name}Altered")

      deactivated_rule.reload
      expect(deactivated_rule).to_not be_active
    end
  end
end
