require "rails_helper"

RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of :login }
  it { is_expected.to validate_presence_of :uid }

  describe "#make_access_token" do
    it "creates a token with the expected payload" do
      user = FactoryBot.build :user

      Timecop.freeze do
        payload = {
          sub: user.login,
          iat: Time.now.to_i
        }

        token = user.make_access_token

        decoded_payload, _ = JWT.decode(
          token,
          Rails.application.secrets.jwt_secret_key,
          true,
          algorithm: "HS256"
        )
        decoded_payload.symbolize_keys!

        expect(decoded_payload).to eq(payload)
      end
    end
  end

  describe ".from_access_token" do
    let(:user) { FactoryBot.create :user }
    let(:payload) { {sub: user.login, iat: Time.now.to_i} }

    subject { User.from_access_token(token) }

    context "when algorithm is not a supported algorithm" do
      let(:token) { JWT.encode(payload, nil, "none") }

      it { is_expected.to be_nil }
    end

    context "when the algorith is HS256" do
      context "and the signature is not valid" do
        let(:token) { JWT.encode(payload, "bad password", "HS256") }

        it { is_expected.to be_nil }
      end

      context "and the signature is valid" do
        let(:token) { JWT.encode(payload, Rails.application.secrets.jwt_secret_key, "HS256") }

        it { is_expected.to eq(user) }
      end
    end
  end

  describe "#assigned_reviews" do
    before do
      stub_request(:get, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+}).to_return(
        status: 200,
        headers: {"Content-Type" => "application/json"},
        body: JSON.dump(json_fixture("pr"))
      )
    end

    let(:user) { FactoryBot.create :user }
    let!(:approved_reviews) { FactoryBot.create_list :reviewer, 2, login: user.login, status: "approved" }
    let!(:pending_reviews) { FactoryBot.create_list :reviewer, 2, login: user.login, status: "pending_review" }

    context "when passed a status" do
      it "only finds records with that status" do
        expect(user.assigned_reviews(status: "approved")).to contain_exactly(*approved_reviews)
      end
    end

    context "when not passed a status" do
      it "finds all the records" do
        expect(user.assigned_reviews).to contain_exactly(*(approved_reviews + pending_reviews))
      end
    end
  end

  describe "#average_review_speed" do
    let(:user) { FactoryBot.create :user }

    it "calls AverageReviewSpeedQuery" do
      since = 20.days.ago
      expect(AverageReviewSpeedQuery).to receive(:new).with(login: user.login, since: since).and_return(instance_double(AverageReviewSpeedQuery, run: 2))
      user.average_review_speed(since: since)
    end
  end
end
