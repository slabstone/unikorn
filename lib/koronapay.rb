# frozen_string_literal: true

require 'http'
require 'money'
require 'nokogiri'
require_relative 'transfer'
require_relative 'utils'

class KoronaPay
  class TariffInfo
    def initialize(info)
      @info = info
    end

    def currencies
      from = Money::Currency.new(@info['sendingCurrency']['code'])
      to = Money::Currency.new(@info['receivingCurrency']['code'])

      Transfer::Currencies.new(from, to)
    end
  end

  def initialize(language)
    Utils.initialize_money

    # KoronaPay uses old (RUR) ISO currency code for RUB
    Money::Currency.inherit('RUB', { iso_numeric: '810' })

    @base_url = 'https://koronapay.com/transfers/online'
    @http_client = HTTP.headers('Accept-Language' => language)
  end

  def countries
    props['props']['initialState']['countries']
  end

  def info(countries, receiving_method = 'cash')
    params = [
      countries.to_h,
      {
        paymentMethod: 'debitCard',
        forTransferRepeat: false
      }
    ].reduce(&:merge)

    result = request('api/transfers/tariffs/info', params)
    result.select { |transfer| transfer['receivingMethod'] == receiving_method }
  end

  def tariffs(transfer)
    params = [
      transfer.to_h,
      {
        paymentMethod: 'debitCard',
        receivingMethod: 'cash',
        paidNotificationEnabled: false
      }
    ].reduce(&:merge)

    request('api/transfers/tariffs', params)
  end

  def currency_pairs(countries)
    response = info(countries)

    response.collect do |transfer|
      TariffInfo.new(transfer).currencies
    end
  end

  def exchange_rate(transfer)
    response = tariffs(transfer)
    response[0]['exchangeRate']
  end

  private

  def request(url, params)
    response = @http_client.get("#{@base_url}/#{url}", params: params)
    JSON.parse(response.to_s)
  end

  def props
    response = @http_client.follow.get(@base_url)
    html = Nokogiri::HTML(response.to_s)
    element = html.at_css('script[id=__NEXT_DATA__]')
    JSON.parse(element.text)
  end
end

module Transfer
  class Currencies
    def to_h
      {
        sendingCurrencyId: from.iso_numeric.to_i,
        receivingCurrencyId: to.iso_numeric.to_i
      }
    end
  end

  class Countries
    def to_h
      {
        sendingCountryId: from.alpha3,
        receivingCountryId: to.alpha3
      }
    end
  end

  class Transfer
    def to_h
      [
        exchange.to_h,
        direction.to_h,
        {
          receivingAmount: Money.from_amount(amount, exchange.to).cents
        }
      ].reduce(&:merge)
    end
  end
end
