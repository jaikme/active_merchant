require 'test_helper'

class WorldPayModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    ActiveMerchant::Billing::Base.integration_mode = :test
  end
  
  def test_service_url_in_test_mode
    assert_equal 'https://select-test.worldpay.com/wcc/purchase', WorldPay.service_url
  end

  def test_service_url_in_production_mode
    ActiveMerchant::Billing::Base.integration_mode = :production
    assert_equal 'https://select.worldpay.com/wcc/purchase', WorldPay.service_url
  end
  
  def test_service_url_in_unknown_mode
    ActiveMerchant::Billing::Base.integration_mode = :invalid_mode
    assert_raises StandardError do
      WorldPay.service_url
    end
  end
  
  def test_notification_method
    assert_instance_of WorldPay::Notification, WorldPay.notification('name=Andrew White')
  end
end 
