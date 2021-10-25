require "rails_helper"

RSpec.describe VerifyWebhookSignature do
  describe ".call" do
    subject { described_class.call(signature: actual, body: body, secret: fake_secret) }

    let(:body) { JSON.dump({foo: "bar"}) }
    let(:fake_secret) { "absolutely-unbelievably-incontroveribly-fake" }

    context "when the actual signature matches the expected signature" do
      let(:actual) { "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), fake_secret, body)}" }

      it { is_expected.to be_truthy }
    end

    context "when the actual signature does not match the expected signature" do
      let(:actual) { "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), "this-secret-is-wrong", body)}" }

      it { is_expected.to be_falsey }
    end

    it "raises exceptions for blank inputs", aggregate_failures: true do
      expect { described_class.call(signature: "", body: body, secret: fake_secret) }.to raise_exception(ArgumentError)
      expect { described_class.call(signature: "foobar", body: body, secret: "") }.to raise_exception(ArgumentError)
    end
  end
end
