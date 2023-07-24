# frozen_string_literal: true

require 'money/currency'

module Transfer
  class Currencies
    attr_reader :from, :to

    def initialize(from, to)
      @from = Money::Currency.new(from)
      @to = Money::Currency.new(to)
    end

    def to_s
      "#{@from} -> #{@to}"
    end
  end
end
