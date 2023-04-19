# frozen_string_literal: true

class ReviewerList
  include Enumerable

  attr_reader :reviewers

  def initialize(reviewers:)
    @reviewers =
      reviewers.map { |reviewer|
        if reviewer.is_a?(String)
          NilStatusUser.new(login: reviewer)
        else
          reviewer
        end
      }
  end

  def each(&block)
    @reviewers
      .select { |reviewer| user_available?(reviewer) }
      .each(&block)
  end

  def choose_reviewer(exclude_list: [])
    each
      .reject { |r| exclude_list.include?(r.login) }
      .sample
  end

  def user_in_list?(login)
    @reviewers.any? { |r| r.login == login }
  end

  private

  def user_available?(user)
    if (status = user.status)
      if status.respond_to?(:indicates_limited_availability?)
        !status.indicates_limited_availability?
      else
        !status.indicatesLimitedAvailability
      end
    else
      true
    end
  end

  class NilStatusUser
    include Comparable

    attr_reader :login

    def initialize(login:)
      @login = login
    end

    def status
      nil
    end
  end
end
