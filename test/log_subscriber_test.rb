require "test_helper"
require "notifiers/base_notifier"
require "active_support/log_subscriber/test_helper"
require "fourseam/log_subscriber"

class LogSubscriberTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper

  def setup
    super
    Fourseam::LogSubscriber.attach_to :push_notification
  end

  def set_logger(logger)
    Fourseam::Base.logger = logger
  end

  def test_deliver_is_notified
    BaseNotifier.welcome.deliver_now!
    wait

    assert_equal(2, @logger.logged(:info).size)
    assert_match(/apn: sent push notification to device-token/, @logger.logged(:info).first)
    assert_match(/fcm: sent push notification to device-token/, @logger.logged(:info).second)

    assert_equal(3, @logger.logged(:debug).size)
    assert_match(/BaseNotifier#welcome: processed outbound push notification in [\d.]+ms/, @logger.logged(:debug).first)
    assert_equal('{"aps":{"alert":"New message!","badge":9,"sound":"bingbong.aiff"}}', @logger.logged(:debug).second)
  ensure
    BaseNotifier.deliveries.clear
  end
end

