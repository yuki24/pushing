require 'test_helper'
require "set"
require "action_dispatch"
require "active_support/time"

require 'notifiers/base_notifier'

class BaseTest < ActiveSupport::TestCase
  test "method call to mail does not raise error" do
    assert_nothing_raised { BaseNotifier.welcome }
  end

  # Basic push notification usage without block
  test "push() should set the device tokens and generate json payload" do
    notification = BaseNotifier.welcome

    assert_equal 'device-token', notification.apn.device_token
    assert_equal <<-JSON.strip,  notification.apn.payload
      {"aps":{"alert":"New message!","badge":9,"sound":"bingbong.aiff"}}
    JSON

    assert_equal <<-JSON.strip, notification.fcm.payload
      {"data":{"message":"Hello FCM!"},"to":"device-token"}
    JSON
  end
end
