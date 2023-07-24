# frozen_string_literal: true

require 'money'

module Utils
  module_function

  def initialize_money
    # round towards zero (truncate)
    Money.rounding_mode = BigDecimal::ROUND_DOWN

    # we don't need localization
    Money.locale_backend = nil
  end
end
