require "test_helper"
require "notifiers/base_notifier"
require "active_support/core_ext/string/strip"
require "active_support/log_subscriber/test_helper"

class LogSubscriberTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper

  def setup
    super
    Pushing::LogSubscriber.attach_to :push_notification
  end

  def set_logger(logger)
    Pushing::Base.logger = logger
  end

  def test_deliver_is_notified
    Pushing::Base.logger.level = 0
    BaseNotifier.welcome.deliver_now!
    wait

    assert_equal(2, @logger.logged(:info).size)
    assert_match(/APN: sent push notification to device-token in development/, @logger.logged(:info).first)
    assert_match(/FCM: sent push notification to device-token/, @logger.logged(:info).second)

    assert_equal(3, @logger.logged(:debug).size)
    assert_match(/BaseNotifier#welcome: processed outbound push notification in [\d.]+ms/, @logger.logged(:debug).first)
    assert_equal(<<-DEBUG_LOG.strip_heredoc.strip, @logger.logged(:debug).second)
      Payload:
          {
            "aps": {
              "alert": "New message!",
              "badge": 9,
              "sound": "bingbong.aiff"
            }
          }
    DEBUG_LOG
  ensure
    BaseNotifier.deliveries.clear
  end

  def test_deliver_is_notified_in_info
    Pushing::Base.logger.level = 1
    BaseNotifier.welcome.deliver_now!
    wait

    assert_equal(2, @logger.logged(:info).size)
    assert_match(/APN: sent push notification to device-token/, @logger.logged(:info).first)
    assert_match(/FCM: sent push notification to device-token/, @logger.logged(:info).second)

    assert_equal 0, @logger.logged(:debug).size
  ensure
    BaseNotifier.deliveries.clear
  end

  def test_deliver_is_not_notified_in_warn
    Pushing::Base.logger.level = 2
    BaseNotifier.welcome.deliver_now!
    wait

    assert_equal 0, @logger.logged(:info).size
    assert_equal 0, @logger.logged(:debug).size
  ensure
    BaseNotifier.deliveries.clear
  end
end
