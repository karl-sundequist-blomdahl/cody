# frozen_string_literal: true

class ReviewRuleBaseMatch < ReviewRule
  validates :ref_match, presence: true

  def ref_match_regex
    @ref_match_regex ||= Regexp.new(ref_match, timeout: 3)
  end

  def matches?(pull_request_hash)
    pull_request_hash.dig("base", "ref") =~ ref_match_regex
  end
end
