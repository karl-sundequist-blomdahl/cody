require "rails_helper"

RSpec.describe ReviewRuleBaseMatch, type: :model do
  it { is_expected.to validate_presence_of :ref_match }

  let(:ref_match) { "release" }
  let(:rule) { build :review_rule_base_match, ref_match: ref_match }

  describe "#ref_match_regex" do
    subject(:ref_match_regex) { rule.ref_match_regex }

    it { is_expected.to eq(/#{ref_match}/) }
  end

  describe "#matches?" do
    subject(:rule_matches) { rule.matches?(pull_request_hash) }

    let(:pull_request_hash) do
      {
        "number" => "42",
        "base" => {
          "ref" => ref
        }
      }
    end

    context "when the base ref match" do
      let(:ref) { "release" }

      it { is_expected.to be_truthy }
    end

    context "when none of the base refs match" do
      let(:ref) { "main" }

      it { is_expected.to be_falsey }
    end
  end
end
