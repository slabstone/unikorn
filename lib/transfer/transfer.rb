# frozen_string_literal: true

require 'money'

module Transfer
  class Transfer
    attr_reader :direction, :exchange, :amount

    def initialize(direction, exchange, amount)
      @direction = direction
      @exchange = exchange
      @amount = amount
    end
  end
end
