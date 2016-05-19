require 'test_helper'

class MundipaggTest < Test::Unit::TestCase
  def setup
    @gateway = MundipaggGateway.new(merchant_key: 'dummy')

    @credit_card = credit_card('4000100011112224')

    @amount = 10000
    @declined_amount = 150100
    @timeout_amount = 105050

    @options = {
      order_id: '123123'
    }
  end

  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)

    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response

    assert_equal '56cd29e0-e9bb-41c5-b77a-53013fa74cf5', response.authorization
    assert response.test?
  end

  def test_failed_purchase
    @gateway.expects(:ssl_post).returns(failed_purchase_response)

    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert_equal Gateway::STANDARD_ERROR_CODE[:card_declined], response.error_code
  end

  def test_successful_authorize
    @gateway.expects(:ssl_post).returns(successful_authorize_response)

    auth = @gateway.authorize(@amount, @credit_card, @options)
    assert_success auth
  end

  def test_failed_authorize
    @gateway.expects(:ssl_post).returns(failed_authorize_response)

    auth = @gateway.authorize(@amount, @credit_card, @options)
    assert_failure auth
  end

  def test_successful_capture
    @gateway.expects(:ssl_post).returns(successful_capture_response)

    response = @gateway.capture(@amount, response)
    assert_success capture
  end

  def test_failed_capture
    @gateway.expects(:ssl_post).returns(failed_capture_response)

    response = @gateway.capture(@amount, response)
    assert_failure capture
  end

  def test_successful_refund
    @gateway.expects(:ssl_post).returns(successful_refund_response)

    response = @gateway.refund(@amount, response) 
    assert_success refund
  end

  def test_failed_refund
    @gateway.expects(:ssl_post).returns(failed_refund_response)

    response = @gateway.refund(@amount, response)
    assert_failure refund
  end

  def test_successful_void
  end

  def test_failed_void
  end

  def test_successful_verify
  end

  def test_successful_verify_with_failed_void
  end

  def test_failed_verify
  end

  def test_scrub
    assert @gateway.supports_scrubbing?
    assert_equal @gateway.scrub(pre_scrubbed), post_scrubbed
  end

  private

  def pre_scrubbed
    <<-PRE_SCRUBBED
      opening connection to api.pagar.me:443...
      opened
      starting SSL for api.pagar.me:443...
      SSL established
      <- "POST /1/transactions HTTP/1.1\r\nContent-Type: application/x-www-form-urlencoded\r\nAuthorization: Basic YWtfdGVzdF9sTmxMNHF3Z0RVQ1VoQk1PWElqRnBSSmdXSkpOZjM6eA==\r\nUser-Agent: Pagar.me/1 ActiveMerchant/1.58.0\r\nAccept-Encoding: deflate\r\nAccept: */*\r\nConnection: close\r\nHost: api.pagar.me\r\nContent-Length: 196\r\n\r\n"
      <- "amount=1000&payment_method=credit_card&card_number=4242424242424242&card_holder_name=Richard+Deschamps&card_expiration_date=9%2F2017&card_cvv=123&metadata[description]=ActiveMerchant+Test+Purchase"
      -> "HTTP/1.1 200 OK\r\n"
      -> "Access-Control-Allow-Credentials: true\r\n"
      -> "Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-HTTP-Method-Override\r\n"
      -> "Access-Control-Allow-Methods: GET,PUT,POST,DELETE\r\n"
      -> "Access-Control-Allow-Origin: *\r\n"
      -> "Charset: utf-8\r\n"
      -> "Content-Type: application/json\r\n"
      -> "Date: Wed, 23 Mar 2016 08:17:52 GMT\r\n"
      -> "ETag: \"1486888623\"\r\n"
      -> "Server: nginx\r\n"
      -> "X-Powered-By: Express\r\n"
      -> "X-Response-Time: 260ms\r\n"
      -> "Content-Length: 1217\r\n"
      -> "Connection: Close\r\n"
      -> "Set-Cookie: visid_incap_166741=4xzkgPXeQ66jO1Z91iibOjxR8lYAAAAAQUIPAAAAAADBzoQck8nwH8iJzqUkDgR6; expires=Wed, 22 Mar 2017 14:07:58 GMT; path=/; Domain=.pagar.me\r\n"
      -> "Set-Cookie: nlbi_166741=XR6HTRng0zFBQUS2W7H6TQAAAADCwTVJNcjRvaX6/996Dj8I; path=/; Domain=.pagar.me\r\n"
      -> "Set-Cookie: incap_ses_297_166741=4loNMgeLdj0PSeV/BCgfBDxR8lYAAAAAgi6H8uNqma8hraBXzDFdzQ==; path=/; Domain=.pagar.me\r\n"
      -> "X-Iinfo: 6-56899509-56899511 NNNN CT(143 143 0) RT(1458721083333 27) q(0 0 3 -1) r(7 7) U6\r\n"
      -> "X-CDN: Incapsula\r\n"
      -> "\r\n"
      reading 1217 bytes...
      -> "{\"object\":\"transaction\",\"status\":\"paid\",\"refuse_reason\":null,\"status_reason\":\"acquirer\",\"acquirer_response_code\":\"00\",\"acquirer_name\":\"development\",\"authorization_code\":\"606507\",\"soft_descriptor\":null,\"tid\":1458721084304,\"nsu\":1458721084304,\"date_created\":\"2016-03-23T08:18:04.162Z\",\"date_updated\":\"2016-03-23T08:18:04.388Z\",\"amount\":1000,\"authorized_amount\":1000,\"paid_amount\":1000,\"refunded_amount\":0,\"installments\":1,\"id\":428211,\"cost\":65,\"card_holder_name\":\"Richard Deschamps\",\"card_last_digits\":\"4242\",\"card_first_digits\":\"424242\",\"card_brand\":\"visa\",\"postback_url\":null,\"payment_method\":\"credit_card\",\"capture_method\":\"ecommerce\",\"antifraud_score\":null,\"boleto_url\":null,\"boleto_barcode\":null,\"boleto_expiration_date\":null,\"referer\":\"api_key\",\"ip\":\"179.191.82.50\",\"subscription_id\":null,\"phone\":null,\"address\":null,\"customer\":null,\"card\":{\"object\":\"card\",\"id\":\"card_cim4ccq3p00q1ju6e4aw4tdon\",\"date_created\":\"2016-03-23T04:19:38.917Z\",\"date_updated\":\"2016-03-23T04:19:39.160Z\",\"brand\":\"visa\",\"holder_name\":\"Richard Deschamps\",\"first_digits\":\"424242\",\"last_digits\":\"4242\",\"country\":\"US\",\"fingerprint\":\"VpmCgO7Ub/rS\",\"valid\":true},\"metadata\":{\"description\":\"ActiveMerchant Test Purchase\"},\"antifraud_metadata\":{}}"
      read 1217 bytes
      Conn close
    PRE_SCRUBBED
  end

  def post_scrubbed
    <<-POST_SCRUBBED
      opening connection to api.pagar.me:443...
      opened
      starting SSL for api.pagar.me:443...
      SSL established
      <- "POST /1/transactions HTTP/1.1\r\nContent-Type: application/x-www-form-urlencoded\r\nAuthorization: Basic [FILTERED]==\r\nUser-Agent: Pagar.me/1 ActiveMerchant/1.58.0\r\nAccept-Encoding: deflate\r\nAccept: */*\r\nConnection: close\r\nHost: api.pagar.me\r\nContent-Length: 196\r\n\r\n"
      <- "amount=1000&payment_method=credit_card&card_number=[FILTERED]&card_holder_name=Richard+Deschamps&card_expiration_date=9%2F2017&card_cvv=[FILTERED]&metadata[description]=ActiveMerchant+Test+Purchase"
      -> "HTTP/1.1 200 OK\r\n"
      -> "Access-Control-Allow-Credentials: true\r\n"
      -> "Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-HTTP-Method-Override\r\n"
      -> "Access-Control-Allow-Methods: GET,PUT,POST,DELETE\r\n"
      -> "Access-Control-Allow-Origin: *\r\n"
      -> "Charset: utf-8\r\n"
      -> "Content-Type: application/json\r\n"
      -> "Date: Wed, 23 Mar 2016 08:17:52 GMT\r\n"
      -> "ETag: \"1486888623\"\r\n"
      -> "Server: nginx\r\n"
      -> "X-Powered-By: Express\r\n"
      -> "X-Response-Time: 260ms\r\n"
      -> "Content-Length: 1217\r\n"
      -> "Connection: Close\r\n"
      -> "Set-Cookie: visid_incap_166741=4xzkgPXeQ66jO1Z91iibOjxR8lYAAAAAQUIPAAAAAADBzoQck8nwH8iJzqUkDgR6; expires=Wed, 22 Mar 2017 14:07:58 GMT; path=/; Domain=.pagar.me\r\n"
      -> "Set-Cookie: nlbi_166741=XR6HTRng0zFBQUS2W7H6TQAAAADCwTVJNcjRvaX6/996Dj8I; path=/; Domain=.pagar.me\r\n"
      -> "Set-Cookie: incap_ses_297_166741=4loNMgeLdj0PSeV/BCgfBDxR8lYAAAAAgi6H8uNqma8hraBXzDFdzQ==; path=/; Domain=.pagar.me\r\n"
      -> "X-Iinfo: 6-56899509-56899511 NNNN CT(143 143 0) RT(1458721083333 27) q(0 0 3 -1) r(7 7) U6\r\n"
      -> "X-CDN: Incapsula\r\n"
      -> "\r\n"
      reading 1217 bytes...
      -> "{\"object\":\"transaction\",\"status\":\"paid\",\"refuse_reason\":null,\"status_reason\":\"acquirer\",\"acquirer_response_code\":\"00\",\"acquirer_name\":\"development\",\"authorization_code\":\"606507\",\"soft_descriptor\":null,\"tid\":1458721084304,\"nsu\":1458721084304,\"date_created\":\"2016-03-23T08:18:04.162Z\",\"date_updated\":\"2016-03-23T08:18:04.388Z\",\"amount\":1000,\"authorized_amount\":1000,\"paid_amount\":1000,\"refunded_amount\":0,\"installments\":1,\"id\":428211,\"cost\":65,\"card_holder_name\":\"Richard Deschamps\",\"card_last_digits\":\"4242\",\"card_first_digits\":\"424242\",\"card_brand\":\"visa\",\"postback_url\":null,\"payment_method\":\"credit_card\",\"capture_method\":\"ecommerce\",\"antifraud_score\":null,\"boleto_url\":null,\"boleto_barcode\":null,\"boleto_expiration_date\":null,\"referer\":\"api_key\",\"ip\":\"179.191.82.50\",\"subscription_id\":null,\"phone\":null,\"address\":null,\"customer\":null,\"card\":{\"object\":\"card\",\"id\":\"card_cim4ccq3p00q1ju6e4aw4tdon\",\"date_created\":\"2016-03-23T04:19:38.917Z\",\"date_updated\":\"2016-03-23T04:19:39.160Z\",\"brand\":\"visa\",\"holder_name\":\"Richard Deschamps\",\"first_digits\":\"424242\",\"last_digits\":\"4242\",\"country\":\"US\",\"fingerprint\":\"VpmCgO7Ub/rS\",\"valid\":true},\"metadata\":{\"description\":\"ActiveMerchant Test Purchase\"},\"antifraud_metadata\":{}}"
      read 1217 bytes
      Conn close
    POST_SCRUBBED
  end

  def successful_purchase_response
    <<-SUCCESS_RESPONSE
      {
        "acquirer_name": "development",
        "acquirer_response_code": "00",
        "address": null,
        "amount": 1000,
        "antifraud_metadata": {},
        "antifraud_score": null,
        "authorization_code": "799941",
        "authorized_amount": 1000,
        "boleto_barcode": null,
        "boleto_expiration_date": null,
        "boleto_url": null,
        "capture_method": "ecommerce",
        "card": {
          "brand": "visa",
          "country": "US",
          "date_created": "2015-11-06T03:39:13.000Z",
          "date_updated": "2016-03-22T20:40:02.907Z",
          "fingerprint": "W8EBIq2PN+qB",
          "first_digits": "424242",
          "holder_name": "Richard Deschamps",
          "id": "card_cign456uw00rsyp6d5qq0og97",
          "last_digits": "4242",
          "object": "card",
          "valid": true
        },
        "card_brand": "visa",
        "card_first_digits": "424242",
        "card_holder_name": "Richard Deschamps",
        "card_last_digits": "4242",
        "cost": 65,
        "customer": null,
        "date_created": "2016-03-22T20:40:02.917Z",
        "date_updated": "2016-03-22T20:40:03.193Z",
        "id": 427312,
        "installments": 1,
        "ip": "179.191.82.50",
        "metadata": {},
        "nsu": 1458679203081,
        "object": "transaction",
        "paid_amount": 1000,
        "payment_method": "credit_card",
        "phone": null,
        "postback_url": null,
        "referer": "api_key",
        "refunded_amount": 0,
        "refuse_reason": null,
        "soft_descriptor": null,
        "status": "paid",
        "status_reason": "acquirer",
        "subscription_id": null,
        "tid": 1458679203081
      }
    SUCCESS_RESPONSE
  end

  def failed_purchase_response
    <<-FAILED_RESPONSE
      {
        "acquirer_name": "development",
        "acquirer_response_code": "88",
        "address": null,
        "amount": 1000,
        "antifraud_metadata": {},
        "antifraud_score": null,
        "authorization_code": null,
        "authorized_amount": 0,
        "boleto_barcode": null,
        "boleto_expiration_date": null,
        "boleto_url": null,
        "capture_method": "ecommerce",
        "card": {
            "brand": "visa",
            "country": "US",
            "date_created": "2015-11-06T03:39:13.000Z",
            "date_updated": "2016-03-22T20:40:02.907Z",
            "fingerprint": "W8EBIq2PN+qB",
            "first_digits": "424242",
            "holder_name": "Richard Deschamps",
            "id": "card_cign456uw00rsyp6d5qq0og97",
            "last_digits": "4242",
            "object": "card",
            "valid": true
        },
        "card_brand": "visa",
        "card_first_digits": "424242",
        "card_holder_name": "Richard Deschamps",
        "card_last_digits": "4242",
        "cost": 0,
        "customer": null,
        "date_created": "2016-03-23T08:44:29.178Z",
        "date_updated": "2016-03-23T08:44:29.716Z",
        "id": 428235,
        "installments": 1,
        "ip": "179.191.82.50",
        "metadata": {},
        "nsu": 1458722669610,
        "object": "transaction",
        "paid_amount": 0,
        "payment_method": "credit_card",
        "phone": null,
        "postback_url": null,
        "referer": "api_key",
        "refunded_amount": 0,
        "refuse_reason": "acquirer",
        "soft_descriptor": null,
        "status": "refused",
        "status_reason": "acquirer",
        "subscription_id": null,
        "tid": 1458722669610
      }
    FAILED_RESPONSE
  end

  def successful_authorize_response
    <<-SUCCESS_RESPONSE
      {
        "acquirer_name": "development",
        "acquirer_response_code": "00",
        "address": null,
        "amount": 1000,
        "antifraud_metadata": {},
        "antifraud_score": null,
        "authorization_code": "231072",
        "authorized_amount": 1000,
        "boleto_barcode": null,
        "boleto_expiration_date": null,
        "boleto_url": null,
        "capture_method": "ecommerce",
        "card": {
            "brand": "visa",
            "country": "US",
            "date_created": "2015-11-06T03:39:13.000Z",
            "date_updated": "2016-03-22T20:40:02.907Z",
            "fingerprint": "W8EBIq2PN+qB",
            "first_digits": "424242",
            "holder_name": "Richard Deschamps",
            "id": "card_cign456uw00rsyp6d5qq0og97",
            "last_digits": "4242",
            "object": "card",
            "valid": true
        },
        "card_brand": "visa",
        "card_first_digits": "424242",
        "card_holder_name": "Richard Deschamps",
        "card_last_digits": "4242",
        "cost": 0,
        "customer": null,
        "date_created": "2016-03-24T18:29:56.523Z",
        "date_updated": "2016-03-24T18:29:56.742Z",
        "id": 429356,
        "installments": 1,
        "ip": "179.191.82.50",
        "metadata": {},
        "nsu": 1458844196661,
        "object": "transaction",
        "paid_amount": 0,
        "payment_method": "credit_card",
        "phone": null,
        "postback_url": null,
        "referer": "api_key",
        "refunded_amount": 0,
        "refuse_reason": null,
        "soft_descriptor": null,
        "status": "authorized",
        "status_reason": "acquirer",
        "subscription_id": null,
        "tid": 1458844196661
      }
    SUCCESS_RESPONSE
  end

  def failed_authorize_response
    <<-FAILED_RESPONSE
      {
        "acquirer_name": "development",
        "acquirer_response_code": "88",
        "address": null,
        "amount": 1000,
        "antifraud_metadata": {},
        "antifraud_score": null,
        "authorization_code": null,
        "authorized_amount": 0,
        "boleto_barcode": null,
        "boleto_expiration_date": null,
        "boleto_url": null,
        "capture_method": "ecommerce",
        "card": {
            "brand": "visa",
            "country": "US",
            "date_created": "2015-11-06T03:39:13.000Z",
            "date_updated": "2016-03-22T20:40:02.907Z",
            "fingerprint": "W8EBIq2PN+qB",
            "first_digits": "424242",
            "holder_name": "Richard Deschamps",
            "id": "card_cign456uw00rsyp6d5qq0og97",
            "last_digits": "4242",
            "object": "card",
            "valid": true
        },
        "card_brand": "visa",
        "card_first_digits": "424242",
        "card_holder_name": "Richard Deschamps",
        "card_last_digits": "4242",
        "cost": 0,
        "customer": null,
        "date_created": "2016-03-24T18:54:03.086Z",
        "date_updated": "2016-03-24T18:54:03.458Z",
        "id": 429402,
        "installments": 1,
        "ip": "179.191.82.50",
        "metadata": {},
        "nsu": 1458845643337,
        "object": "transaction",
        "paid_amount": 0,
        "payment_method": "credit_card",
        "phone": null,
        "postback_url": null,
        "referer": "api_key",
        "refunded_amount": 0,
        "refuse_reason": "acquirer",
        "soft_descriptor": null,
        "status": "refused",
        "status_reason": "acquirer",
        "subscription_id": null,
        "tid": 1458845643337
      }
    FAILED_RESPONSE
  end

  def successful_capture_response
    <<-SUCCESS_RESPONSE
      {
        "acquirer_name": "development",
        "acquirer_response_code": "00",
        "address": null,
        "amount": 1000,
        "antifraud_metadata": {},
        "antifraud_score": null,
        "authorization_code": "231072",
        "authorized_amount": 1000,
        "boleto_barcode": null,
        "boleto_expiration_date": null,
        "boleto_url": null,
        "capture_method": "ecommerce",
        "card": {
            "brand": "visa",
            "country": "US",
            "date_created": "2015-11-06T03:39:13.000Z",
            "date_updated": "2016-03-22T20:40:02.907Z",
            "fingerprint": "W8EBIq2PN+qB",
            "first_digits": "424242",
            "holder_name": "Richard Deschamps",
            "id": "card_cign456uw00rsyp6d5qq0og97",
            "last_digits": "4242",
            "object": "card",
            "valid": true
        },
        "card_brand": "visa",
        "card_first_digits": "424242",
        "card_holder_name": "Richard Deschamps",
        "card_last_digits": "4242",
        "cost": 65,
        "customer": null,
        "date_created": "2016-03-24T18:29:56.523Z",
        "date_updated": "2016-03-24T21:35:14.237Z",
        "id": 429356,
        "installments": 1,
        "ip": "179.191.82.50",
        "metadata": {},
        "nsu": "1458844196661",
        "object": "transaction",
        "paid_amount": 1000,
        "payment_method": "credit_card",
        "phone": null,
        "postback_url": null,
        "referer": "api_key",
        "refunded_amount": 0,
        "refuse_reason": null,
        "soft_descriptor": null,
        "status": "paid",
        "status_reason": "acquirer",
        "subscription_id": null,
        "tid": "1458844196661"
      }
    SUCCESS_RESPONSE
  end

  def failed_capture_response
  <<-FAILED_RESPONSE
    {
      "errors": [
        {
          "message": "Transação com status 'captured' não pode ser capturada.",
          "parameter_name": null,
          "type": "action_forbidden"
        }
      ],
      "method": "post",
      "url": "/transactions/429356/capture"
    }
  FAILED_RESPONSE
  end

  def successful_refund_response
  <<-SUCCESS_RESPONSE
    {
      "acquirer_name": "development",
      "acquirer_response_code": "00",
      "address": null,
      "amount": 1000,
      "antifraud_metadata": {},
      "antifraud_score": null,
      "authorization_code": "231072",
      "authorized_amount": 1000,
      "boleto_barcode": null,
      "boleto_expiration_date": null,
      "boleto_url": null,
      "capture_method": "ecommerce",
      "card": {
        "brand": "visa",
        "country": "US",
        "date_created": "2015-11-06T03:39:13.000Z",
        "date_updated": "2016-03-22T20:40:02.907Z",
        "fingerprint": "W8EBIq2PN+qB",
        "first_digits": "424242",
        "holder_name": "Richard Deschamps",
        "id": "card_cign456uw00rsyp6d5qq0og97",
        "last_digits": "4242",
        "object": "card",
        "valid": true
      },
      "card_brand": "visa",
      "card_first_digits": "424242",
      "card_holder_name": "Richard Deschamps",
      "card_last_digits": "4242",
      "cost": 0,
      "customer": null,
      "date_created": "2016-03-24T18:29:56.523Z",
      "date_updated": "2016-03-29T17:37:20.035Z",
      "id": 429356,
      "installments": 1,
      "ip": "179.191.82.50",
      "metadata": {},
      "nsu": "1458844196661",
      "object": "transaction",
      "paid_amount": 1000,
      "payment_method": "credit_card",
      "phone": null,
      "postback_url": null,
      "referer": "api_key",
      "refunded_amount": 1000,
      "refuse_reason": null,
      "soft_descriptor": null,
      "status": "refunded",
      "status_reason": "acquirer",
      "subscription_id": null,
      "tid": "1458844196661"
    }
  SUCCESS_RESPONSE
  end

  def failed_refund_response
  <<-FAILED_RESPONSE
    {
      "errors": [
        {
          "message": "Transação já estornada",
          "parameter_name": null,
          "type": "action_forbidden"
        }
      ],
      "method": "post",
      "url": "/transactions/429356/refund"
    }
  FAILED_RESPONSE
  end

  def successful_void_response
  <<-SUCCESS_RESPONSE
    {
      "acquirer_name": "pagarme",
      "acquirer_response_code": "00",
      "address": null,
      "amount": 1000,
      "antifraud_metadata": {},
      "antifraud_score": null,
      "authorization_code": "420653",
      "authorized_amount": 1000,
      "boleto_barcode": null,
      "boleto_expiration_date": null,
      "boleto_url": null,
      "capture_method": "ecommerce",
      "card": {
        "brand": "visa",
        "country": "US",
        "date_created": "2016-04-28T19:04:17.522Z",
        "date_updated": "2016-04-28T19:04:17.744Z",
        "fingerprint": "W8EBIq2PN+qB",
        "first_digits": "424242",
        "holder_name": "Richard Deschamps",
        "id": "card_cinknt1td006ffo6dr0jjitj4",
        "last_digits": "4242",
        "object": "card",
        "valid": true
      },
      "card_brand": "visa",
      "card_first_digits": "424242",
      "card_holder_name": "Richard Deschamps",
      "card_last_digits": "4242",
      "cost": 0,
      "customer": null,
      "date_created": "2016-04-28T19:04:17.528Z",
      "date_updated": "2016-04-28T19:07:07.905Z",
      "id": 472218,
      "installments": 1,
      "ip": "179.185.132.108",
      "metadata": {},
      "nsu": 472218,
      "object": "transaction",
      "paid_amount": 0,
      "payment_method": "credit_card",
      "phone": null,
      "postback_url": null,
      "referer": "api_key",
      "refunded_amount": 1000,
      "refuse_reason": null,
      "soft_descriptor": null,
      "status": "refunded",
      "status_reason": "acquirer",
      "subscription_id": null,
      "tid": 472218
    }
  SUCCESS_RESPONSE
  end

  def failed_void_response
  <<-FAILED_RESPONSE
    {
      "errors": [
        {
          "message": "Transação já estornada",
          "parameter_name": null,
          "type": "action_forbidden"
        }
      ],
      "method": "post",
      "url": "/transactions/472218/refund"
    }
  FAILED_RESPONSE
  end

  def successful_verify_response
  <<-SUCCESS_RESPONSE
    {
      "acquirer_name": "pagarme",
      "acquirer_response_code": "00",
      "address": null,
      "amount": 127,
      "antifraud_metadata": {},
      "antifraud_score": null,
      "authorization_code": "713869",
      "authorized_amount": 127,
      "boleto_barcode": null,
      "boleto_expiration_date": null,
      "boleto_url": null,
      "capture_method": "ecommerce",
      "card": {
        "brand": "visa",
        "country": "US",
        "date_created": "2016-05-03T22:15:08.888Z",
        "date_updated": "2016-05-03T22:15:09.140Z",
        "fingerprint": "gulv5VbV4RnS",
        "first_digits": "424242",
        "holder_name": "Richard Deschamps",
        "id": "card_cinrztr2w003sxc6djpqm0toe",
        "last_digits": "4242",
        "object": "card",
        "valid": true
      },
      "card_brand": "visa",
      "card_first_digits": "424242",
      "card_holder_name": "Richard Deschamps",
      "card_last_digits": "4242",
      "cost": 0,
      "customer": null,
      "date_created": "2016-05-03T22:15:18.697Z",
      "date_updated": "2016-05-03T22:15:18.900Z",
      "id": 476135,
      "installments": 1,
      "ip": "179.191.82.50",
      "metadata": {},
      "nsu": 476135,
      "object": "transaction",
      "paid_amount": 0,
      "payment_method": "credit_card",
      "phone": null,
      "postback_url": null,
      "referer": "api_key",
      "refunded_amount": 0,
      "refuse_reason": null,
      "soft_descriptor": null,
      "status": "authorized",
      "status_reason": "antifraud",
      "subscription_id": null,
      "tid": 476135
    }
  SUCCESS_RESPONSE
  end

  def successful_verify_void_response
  <<-SUCCESS_RESPONSE
    {
      "acquirer_name": "pagarme",
      "acquirer_response_code": "00",
      "address": null,
      "amount": 127,
      "antifraud_metadata": {},
      "antifraud_score": null,
      "authorization_code": "713869",
      "authorized_amount": 127,
      "boleto_barcode": null,
      "boleto_expiration_date": null,
      "boleto_url": null,
      "capture_method": "ecommerce",
      "card": {
        "brand": "visa",
        "country": "US",
        "date_created": "2016-05-03T22:15:08.888Z",
        "date_updated": "2016-05-03T22:15:09.140Z",
        "fingerprint": "gulv5VbV4RnS",
        "first_digits": "424242",
        "holder_name": "Richard Deschamps",
        "id": "card_cinrztr2w003sxc6djpqm0toe",
        "last_digits": "4242",
        "object": "card",
        "valid": true
      },
      "card_brand": "visa",
      "card_first_digits": "424242",
      "card_holder_name": "Richard Deschamps",
      "card_last_digits": "4242",
      "cost": 0,
      "customer": null,
      "date_created": "2016-05-03T22:15:18.697Z",
      "date_updated": "2016-05-04T19:48:48.294Z",
      "id": 476135,
      "installments": 1,
      "ip": "179.191.82.50",
      "metadata": {},
      "nsu": 476135,
      "object": "transaction",
      "paid_amount": 0,
      "payment_method": "credit_card",
      "phone": null,
      "postback_url": null,
      "referer": "api_key",
      "refunded_amount": 127,
      "refuse_reason": null,
      "soft_descriptor": null,
      "status": "refunded",
      "status_reason": "acquirer",
      "subscription_id": null,
      "tid": 476135
    }
  SUCCESS_RESPONSE
  end

  def failed_verify_response
  <<-FAILED_RESPONSE
    {
      "acquirer_name": "pagarme",
      "acquirer_response_code": "88",
      "address": null,
      "amount": 127,
      "antifraud_metadata": {},
      "antifraud_score": null,
      "authorization_code": null,
      "authorized_amount": 0,
      "boleto_barcode": null,
      "boleto_expiration_date": null,
      "boleto_url": null,
      "capture_method": "ecommerce",
      "card": {
        "brand": "visa",
        "country": "US",
        "date_created": "2016-05-03T22:15:08.888Z",
        "date_updated": "2016-05-03T22:15:09.140Z",
        "fingerprint": "gulv5VbV4RnS",
        "first_digits": "424242",
        "holder_name": "Richard Deschamps",
        "id": "card_cinrztr2w003sxc6djpqm0toe",
        "last_digits": "4242",
        "object": "card",
        "valid": true
      },
      "card_brand": "visa",
      "card_first_digits": "424242",
      "card_holder_name": "Richard Deschamps",
      "card_last_digits": "4242",
      "cost": 0,
      "customer": null,
      "date_created": "2016-05-03T22:23:26.282Z",
      "date_updated": "2016-05-03T22:23:26.505Z",
      "id": 476143,
      "installments": 1,
      "ip": "179.191.82.50",
      "metadata": {},
      "nsu": 476143,
      "object": "transaction",
      "paid_amount": 0,
      "payment_method": "credit_card",
      "phone": null,
      "postback_url": null,
      "referer": "api_key",
      "refunded_amount": 0,
      "refuse_reason": "acquirer",
      "soft_descriptor": null,
      "status": "refused",
      "status_reason": "acquirer",
      "subscription_id": null,
      "tid": 476143
    }
  FAILED_RESPONSE
  end

  def failed_error_response
    <<-FAILED_RESPONSE
    {
      "errors": [
        {
          "message": "Internal server error.",
          "parameter_name": null,
          "type": "internal_error"
        }
      ],
      "method": "post",
      "url": "/transactions"
    }
  FAILED_RESPONSE
  end

  def failed_json_response
  <<-SUCCESS_RESPONSE
    {
      foo: bar
    }
  SUCCESS_RESPONSE
  end
end
