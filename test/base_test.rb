require 'test_helper'
require "set"
require "action_dispatch"
require "active_support/time"

require 'notifiers/base_notifier'

class BaseTest < ActiveSupport::TestCase
  setup do
    BaseNotifier.deliveries.clear
  end

  test "method call to mail does not raise error" do
    assert_nothing_raised { BaseNotifier.welcome }
  end

  # Class level API with method missing
  test "should respond to action methods" do
    assert_respond_to BaseNotifier, :welcome
    assert_not BaseNotifier.respond_to?(:push)
  end

  # Basic push notification usage without block
  test "push() should set the device tokens and generate json payload" do
    notification = BaseNotifier.welcome

    assert_equal 'device-token', notification.apn.device_token

    apn_payload = {
      aps: {
        alert: "New message!",
        badge: 9,
        sound: "bingbong.aiff"
      }
    }
    assert_equal apn_payload, notification.apn.payload

    fcm_payload = {
      data: {
        message: "Hello FCM!"
      },
      to: "device-token"
    }
    assert_equal fcm_payload, notification.fcm.payload
  end

  test "should be able to render only with a single service" do
    BaseNotifier.with_apn_template.deliver_now!
    assert_equal 1, BaseNotifier.deliveries.length
    assert_equal 1, BaseNotifier.deliveries.apn.length
    assert_equal 0, BaseNotifier.deliveries.fcm.length

    BaseNotifier.with_fcm_template.deliver_now!
    assert_equal 2, BaseNotifier.deliveries.length
    assert_equal 1, BaseNotifier.deliveries.apn.length
    assert_equal 1, BaseNotifier.deliveries.fcm.length
  end

  test "calling deliver on the action should increment the deliveries collection if using the test notifier" do
    BaseNotifier.welcome.deliver_now!
    assert_equal 2, BaseNotifier.deliveries.length
    assert_equal 1, BaseNotifier.deliveries.apn.length
    assert_equal 1, BaseNotifier.deliveries.fcm.length
  end

  test "should raise if missing template" do
    assert_raises ActionView::MissingTemplate do
      BaseNotifier.missing_apn_template.deliver_now!
    end
    assert_raises ActionView::MissingTemplate do
      BaseNotifier.missing_fcm_template.deliver_now!
    end

    assert_equal 0, BaseNotifier.deliveries.length
  end

  test "the view is not rendered when mail was never called" do
    notification = BaseNotifier.without_push_call
    notification.deliver_now!

    assert_nil notification.apn
    assert_nil notification.fcm
  end

  test "the return value of mailer methods is not relevant" do
    notification = BaseNotifier.with_nil_as_return_value

    apn_payload = {
      aps: {
        alert: "New message!",
      }
    }
    assert_equal apn_payload, notification.apn.payload
    assert_equal 'device-token', notification.apn.device_token

    notification.deliver_now!
  end
end
