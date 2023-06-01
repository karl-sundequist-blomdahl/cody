FactoryBot.define do
  factory :review_rule do
    sequence(:name) { |x| "Review Rule #{x}" }
    sequence(:short_code) { |x| "review_rule_#{x}" }
    reviewer { "octocat" }
    repository

    factory :review_rule_file_match, class: ReviewRuleFileMatch
    factory :review_rule_diff_match, class: ReviewRuleDiffMatch
    factory :review_rule_always, class: ReviewRuleAlways
    factory :review_rule_base_match, class: ReviewRuleBaseMatch
  end
end
