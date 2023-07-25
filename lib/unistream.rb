# frozen_string_literal: true

require 'http'
require 'json'
require_relative 'transfer'

class Unistream
  def initialize(token, user_agent)
    @base_url = 'https://online.unistream.ru/api/card2cash/calculate'

    @token = token
    @user_agent = user_agent
  end

  def calculate(transfer)
    params = [
      transfer.to_h,
      { profile: 'unistream' }
    ].reduce(&:merge)

    response = HTTP.get(@base_url, params: params, headers: headers)
    JSON.parse(response.to_s)
  end

  private

  def headers
    {
      authorization: "Bearer #{@token}",
      'user-agent': @user_agent,
      referer: 'https://unistream.ru/'
    }
  end
end

module Transfer
  class Transfer
    def to_h
      {
        destination: direction.to.alpha3,
        amount: amount,
        currency: exchange.to.iso_code,
        accepted_currency: exchange.from.iso_code
      }
    end
  end
end
