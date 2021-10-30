require "rails_helper"

RSpec.describe ReceiveIssueCommentEvent do
  let!(:repo) { FactoryBot.create :repository }
  let!(:pr) { FactoryBot.create :pull_request, status: "pending_review", repository: repo }

  let(:reviewer) { "aergonaut" }

  let(:payload) do
    json_fixture("issue_comment", number: pr.number, sender: sender, body: comment, name: repo.name, owner: repo.owner)
  end

  let(:job) { ReceiveIssueCommentEvent.new }

  let(:sender) { reviewer }
  let!(:review) { FactoryBot.create(:reviewer, login: reviewer, pull_request: pr) }

  before do
    allow(Repository).to receive(:find_by_full_name).and_return(repo)
  end

  describe "#perform" do
    before do
      stub_request(:post, %r(https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/statuses/[0-9abcdef]{40}))
      stub_request(:get, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+}).to_return(
        body: JSON.dump(pr_response_body),
        status: 200,
        headers: {"Content-Type" => "application/json"}
      )
      stub_request(:patch, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/issues/\d+})
      stub_request(:post, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+/requested_reviewers})
    end

    let(:pr_response_body) { json_fixture("pr") }

    let(:comment) { "foobar" }

    subject { job.perform(payload) }

    it "updates last_commented_at for the reviewer" do
      Timecop.freeze do
        subject
        review.reload
        expect(review.last_commented_at).to be_within(1.second).of(Time.now.utc)
      end
    end

    context "when first_commented_at is nil" do
      it "sets first_commented_at" do
        Timecop.freeze do
          subject
          review.reload
          expect(review.first_commented_at).to be_within(1.second).of(Time.now.utc)
        end
      end
    end

    context "when first_commented_at is not nil" do
      it "does not change first_commented_at" do
        review.first_commented_at = 2.days.ago
        review.save!

        Timecop.freeze do
          expect { subject }.to_not change { review.reload.first_commented_at }
        end
      end
    end
  end

  describe "#comment_replace" do
    let(:comment) { "cody replace foo=BrentW bar=mrpasquini" }

    let(:rule) { FactoryBot.create :review_rule, short_code: "foo", reviewer: acceptable_reviewer }

    before do
      stub_request(:get, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+}).to_return(
        body: JSON.dump(json_fixture("pr")),
        status: 200,
        headers: {"Content-Type" => "application/json"}
      )
      stub_request(:patch, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+$})
      stub_request(:patch, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/issues/\d+})
      stub_request(:post, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+/requested_reviewers})
      stub_request(:delete, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+/requested_reviewers})
        .with(
          body: "{\"reviewers\":[\"aergonaut\"]}"
        )
        .to_return(status: 200, body: "", headers: {})
      stub_request(:get, "https://api.github.com/repos/baxterthehacker/public-repo/pulls/9876/requested_reviewers")
        .to_return(
          status: 200,
          body: JSON.dump({"users" => []}),
          headers: {"Content-Type" => "application/json"}
        )
      stub_request(:delete, "https://api.github.com/repos/baxterthehacker/public-repo/pulls/9876/requested_reviewers")

      FactoryBot.create :reviewer, review_rule: rule, pull_request: pr, login: "aergonaut"
    end

    context "when BrentW is a possible reviewer for the rule" do
      let(:acceptable_reviewer) { "BrentW" }

      it "replaces aergonaut with BrentW" do
        foo_reviewer = pr.reviewers.find_by(review_rule_id: rule.id)

        job.perform(payload)

        expect(Reviewer.exists?(foo_reviewer.id)).to be_falsey
        foo_reviewer = pr.reviewers.find_by(review_rule_id: rule.id)
        expect(foo_reviewer.login).to eq("BrentW")
      end

      it "records the command usage" do
        expect { job.perform(payload) }.to change { CommandInvocation.count }.by(1)
      end
    end

    context "when BrentW is not a possible reviewer for the rule" do
      let(:acceptable_reviewer) { "octocat" }

      it "does not change the reviewer" do
        foo_reviewer = pr.reviewers.find_by(review_rule_id: rule.id)
        expect { job.perform(payload) }.to_not change { foo_reviewer.reload.login }
      end
    end

    context "when the reviewer is specified with an @ sign" do
      let(:comment) { "cody replace foo=@BrentW" }
      let(:acceptable_reviewer) { "BrentW" }

      it "replaces aergonaut with BrentW" do
        foo_reviewer = pr.reviewers.find_by(review_rule_id: rule.id)

        job.perform(payload)

        expect(Reviewer.exists?(foo_reviewer.id)).to be_falsey
        foo_reviewer = pr.reviewers.find_by(review_rule_id: rule.id)
        expect(foo_reviewer.login).to eq("BrentW")
      end
    end

    context "when the reviewer is specified with a space and an @ sign" do
      let(:comment) { "cody replace foo= @BrentW" }
      let(:acceptable_reviewer) { "BrentW" }

      it "replaces aergonaut with BrentW" do
        foo_reviewer = pr.reviewers.find_by(review_rule_id: rule.id)

        job.perform(payload)

        expect(Reviewer.exists?(foo_reviewer.id)).to be_falsey
        foo_reviewer = pr.reviewers.find_by(review_rule_id: rule.id)
        expect(foo_reviewer.login).to eq("BrentW")
      end
    end
  end

  describe "#comment_replace_me" do
    let(:comment) { "cody replace me!" }

    let(:rule) { FactoryBot.create :review_rule, short_code: "foo", reviewer: acceptable_reviewer }

    before do
      stub_request(:get, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+}).to_return(
        body: JSON.dump(json_fixture("pr")),
        status: 200,
        headers: {"Content-Type" => "application/json"}
      )
      stub_request(:patch, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+})
      stub_request(:patch, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/issues/\d+})
      stub_request(:post, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+/requested_reviewers})
      stub_request(:delete, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+/requested_reviewers})
        .with(
          body: JSON.dump({reviewers: ["aergonaut"]})
        )

      allow_any_instance_of(PullRequest).to receive(:commit_authors).and_return(["maverick"])

      FactoryBot.create :reviewer, review_rule: rule, pull_request: pr, login: "aergonaut"
    end

    context "when mrpasquini is a possible reviewer for the rule" do
      let(:acceptable_reviewer) { "mrpasquini" }

      it "replaces aergonaut with mrpasquini" do
        foo_reviewer = pr.reviewers.find_by(review_rule_id: rule.id)

        job.perform(payload)

        expect(Reviewer.exists?(foo_reviewer.id)).to be_falsey
        foo_reviewer = pr.reviewers.find_by(review_rule_id: rule.id)
        expect(foo_reviewer.login).to eq("mrpasquini")
      end
    end

    context "when there is no other possible reviewer for the rule" do
      let(:acceptable_reviewer) { "aergonaut" }

      it "does not replace aergonaut" do
        foo_reviewer = pr.reviewers.find_by(review_rule_id: rule.id)
        expect { job.perform(payload) }.to_not change { foo_reviewer.reload.login }
      end
    end
  end
end
