module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class MundipaggGateway < Gateway
      self.test_url = 'https://sandbox.mundipaggone.com'
      self.live_url = 'https://transactionv2.mundipaggone.com'

      CREDIT_CARD_BRANDS = {
        :visa => 'Visa',
        :master => 'Mastercard',
        :hipercard => 'Hipercard',
        :amex => 'Amex',
        :diners => 'Diners',
        :elo => 'Elo',
        :aura => 'Aura',
        :discover => 'Discover',
        :casa_show => 'CasaShow',
        :hug_car => 'HugCard'
      }

      CREDIT_CARD_OPERATION = {
        :auth_only => 'AuthOnly',
        :auth_and_capture => 'AuthAndCapture'
      }

      # PendingAuthorize and Invalid status is for Recurrency feature only
      CREDIT_CARD_TRANSACTION_STATUS = {
        :authorized_pending_capture => 'AuthorizedPendingCapture',
        :captured => 'Captured',
        :partial_capture => 'PartialCapture',
        :not_authorized => 'NotAuthorized',
        :voided => 'Voided',
        :pending_void => 'PendingVoid',
        :partial_void => 'PartialVoid',
        :refunded => 'Refunded',
        :pending_refund=> 'PendingRefund',
        :partial_refunded => 'PartialRefunded',
        :with_error => 'WithError',
        :not_found_in_acquirer => 'NotFoundInAcquirer',
        :pending_authorize => 'PendingAuthorize',
        :invalid => 'Invalid'
      }


      self.supported_cardtypes = CREDIT_CARD_BRANDS.keys
      self.supported_countries = ['BR']
      self.default_currency = 'BRL'
      self.money_format = :cents
      self.homepage_url = 'http://www.mundipagg.com/'
      self.display_name = 'Mundipagg'

      STANDARD_ERROR_CODE_MAPPING = {
        'card_declined' => STANDARD_ERROR_CODE[:card_declined]
      }

      def initialize(options={})
        requires!(options, :merchant_key)
        @merchant_key = options[:merchant_key]
        super
      end

      def purchase(money, payment, options={})
        options[:operation] = 'AuthAndCapture'
        post = {}
        add_credit_card(post, payment, options)
        add_invoice(post, money, options)

        commit('/Sale/', post)
      end

      def authorize(money, payment, options={})
        options[:operation] = 'AuthOnly'
        post = {}
        add_credit_card(post, payment, options)
        add_invoice(post, money, options)

        commit('/Sale/', post)

      end

      def capture(money, params, options={})
        post = {}
        add_transaction_information(post, money, params)
        commit('/Sale/Capture/', post)
      end
      def void(money, params, options={})
        post = {}
        add_transaction_information(post, money, params)
        commit('/Sale/Cancel/', post)
      end
      alias_method :refund, :void

      def verify(credit_card, options={})
        options[:money] ||= 100
        MultiResponse.run(:use_first_response) do |r|
          r.process { authorize(options[:money], credit_card, options) }
          r.process(:ignore_result) { void(options[:money], r.params, options) }
        end
      end

      def supports_scrubbing?
        true
      end

      def scrub(transcript)
        transcript.
          gsub(%r((Authorization: Basic )\w+), '\1[FILTERED]').
          gsub(%r((card_number=)\d+), '\1[FILTERED]').
          gsub(%r((card_cvv=)\d+), '\1[FILTERED]')
      end

      private

      def add_transaction_information(post, money, params)
        post[:request_key] = params.request_key || ''
        post[:credit_card_transaction_collection] = [{
          amount_in_cents: amount(money),
          transaction_key: params.transaction_key,
          transaction_reference: params.transaction_reference
        }]
        post[:order_key] = params.order_key
      end

      def add_credit_card(post, credit_card, options)
        requires!(options, :operation)

        creditcard = {}

        creditcard[:credit_card_brand] = card_type(credit_card.brand)
        creditcard[:credit_number] = credit_card.number
        creditcard[:card_exp_month] = credit_card.month
        creditcard[:card_exp_year] = credit_card.year
        creditcard[:card_holder_name] = credit_card.name
        creditcard[:card_cvv] = credit_card.verification_value


        creditcard_transaction = {}
        creditcard_transaction[:credit_card] = creditcard
        creditcard_transaction[:credit_card_operation] = options[:operation]

        post[:credit_card_transaction_collection] = [creditcard_transaction]
      end

      def card_type(credit_card_brand)
        CREDIT_CARD_TRANSACTION_STATUS[credit_card_brand.to_sym] if credit_card_brand
      end

      def add_invoice(post, money, options)
        requires!(options, :order_id)

        post[:credit_card_transaction_collection][0][:transaction_reference] = options[:order_id]
        post[:credit_card_transaction_collection][0][:amount_in_cents] = amount(money)
      end

      def add_invoice(post, money, options)
        post[:amount] = amount(money)
        post[:currency] = (options[:currency] || currency(money))
      end

      def commit(action, parameters)
        url = (test? ? test_url : live_url)

        raw_response = response = nil
        begin
          raw_response = ssl_post(url + action, post_data(parameters))
          response = parse(raw_response)
        rescue ResponseError => e
          raw_response = e.response.body
          response = response_error(raw_response)
        rescue JSON::ParserError
          response = json_error(raw_response)
        end

        Response.new(
          success_from(response),
          message_from(response),
          response,
          authorization: authorization_from(response),
          avs_result: AVSResult.new(code: response["some_avs_response_key"]),
          cvv_result: CVVResult.new(response["some_cvv_response_key"]),
          test: test?,
          error_code: error_code_from(response)
        )
      end

      def success_from(response)
      end

      def message_from(response)
      end

      def authorization_from(response)
      end

      def ssl_post(url, data, headers = {})
        headers['MerchantKey'] = @merchant_key
        headers['Accept'] = 'application/json'
        headers['Content-Type'] = 'application/json'
        super
      end

      def parse(body)
        JSON.parse(body)
      end

      def post_data(parameters = {})
        parameters.deep_transform_keys{ |key| key.to_s.camelize }.to_json
      end

      def error_code_from(response)
        unless success_from(response)
          # TODO: lookup error code for this response
        end
      end
    end
  end
end
