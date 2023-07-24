# frozen_string_literal: true

require 'countries'

module Transfer
  class Countries
    attr_reader :from, :to

    def initialize(from, to)
      @from = ISO3166::Country.find_country_by_alpha2(from)
      @to = ISO3166::Country.find_country_by_alpha2(to)
    end
  end
end
