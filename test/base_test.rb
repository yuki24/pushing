require 'test_helper'
require "set"
require "action_dispatch"
require "active_support/time"

require 'notifiers/base_notifier'

class BaseTest < ActiveSupport::TestCase
  setup do
    BaseNotifier.deliveries.clear
  end

  test "method call to notification does not raise error" do
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

  test "should not render if apn device token is falsy" do
    BaseNotifier.with_no_apn_device_token.deliver_now!
    assert_equal 0, BaseNotifier.deliveries.length
    assert_equal 0, BaseNotifier.deliveries.apn.length
    assert_equal 0, BaseNotifier.deliveries.fcm.length
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

  test "the view is not rendered when notification was never called" do
    notification = BaseNotifier.without_push_call
    notification.deliver_now!

    assert_nil notification.apn
    assert_nil notification.fcm
  end

  test "the return value of notifier methods is not relevant" do
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

  # Before and After hooks

  class MyObserver
    def self.delivered_notification(notification, response)
    end
  end

  class MySecondObserver
    def self.delivered_notification(notification, response)
    end
  end

  test "you can register an observer to the notifier object that gets informed on notification delivery" do
    notification_side_effects do
      Pushing::Base.register_observer(MyObserver)
      notification = BaseNotifier.with_apn_template
      assert_called_with(MyObserver, :delivered_notification, [notification, notification.apn]) do
        notification.deliver_now!
      end
    end
  end

  def notification_side_effects
    old_observers = Pushing::Base.class_variable_get(:@@delivery_notification_observers)
    old_delivery_interceptors = Pushing::Base.class_variable_get(:@@delivery_interceptors)
    yield
  ensure
    Pushing::Base.class_variable_set(:@@delivery_notification_observers, old_observers)
    Pushing::Base.class_variable_set(:@@delivery_interceptors, old_delivery_interceptors)
  end

  test "you can register multiple observers to the notification object that both get informed on notification delivery" do
    notification_side_effects do
      Pushing::Base.register_observers(BaseTest::MyObserver, MySecondObserver)
      notification = BaseNotifier.with_apn_template
      assert_called_with(MyObserver, :delivered_notification, [notification, notification.apn]) do
        assert_called_with(MySecondObserver, :delivered_notification, [notification, notification.apn]) do
          notification.deliver_now!
        end
      end
    end
  end

  class MyInterceptor
    def self.delivering_notification(notification); end
    def self.previewing_notification(notification); end
  end

  class MySecondInterceptor
    def self.delivering_notification(notification); end
    def self.previewing_notification(notification); end
  end

  test "you can register an interceptor to the notification object that gets passed the notification object before delivery" do
    notification_side_effects do
      Pushing::Base.register_interceptor(MyInterceptor)
      notification = BaseNotifier.welcome
      assert_called_with(MyInterceptor, :delivering_notification, [notification]) do
        notification.deliver_now!
      end
    end
  end

  test "you can register multiple interceptors to the notification object that both get passed the notification object before delivery" do
    notification_side_effects do
      Pushing::Base.register_interceptors(BaseTest::MyInterceptor, MySecondInterceptor)
      notification = BaseNotifier.welcome
      assert_called_with(MyInterceptor, :delivering_notification, [notification]) do
        assert_called_with(MySecondInterceptor, :delivering_notification, [notification]) do
          notification.deliver_now!
        end
      end
    end
  end

  test "modifying the notification message with a before_action" do
    class BeforeActionNotifier < Pushing::Base
      before_action :filter

      def welcome ; notification ; end

      cattr_accessor :called
      self.called = false

      private
      def filter
        self.class.called = true
      end
    end

    BeforeActionNotifier.welcome.message

    assert BeforeActionNotifier.called, "Before action didn't get called."
  end

  test "modifying the notification message with an after_action" do
    class AfterActionNotifier < Pushing::Base
      after_action :filter

      def welcome ; notification ; end

      cattr_accessor :called
      self.called = false

      private
      def filter
        self.class.called = true
      end
    end

    AfterActionNotifier.welcome.message

    assert AfterActionNotifier.called, "After action didn't get called."
  end

  test "action methods should be refreshed after defining new method" do
    class FooNotifier < Pushing::Base
      # This triggers action_methods.
      respond_to?(:foo)

      def notify
      end
    end

    assert_equal Set.new(["notify"]), FooNotifier.action_methods
  end

  test "notification for process" do
    begin
      events = []
      ActiveSupport::Notifications.subscribe("process.push_notification") do |*args|
        events << ActiveSupport::Notifications::Event.new(*args)
      end

      BaseNotifier.welcome.deliver_now!

      assert_equal 1, events.length
      assert_equal "process.push_notification", events[0].name
      assert_equal "BaseNotifier", events[0].payload[:notifier]
      assert_equal :welcome, events[0].payload[:action]
      assert_equal [], events[0].payload[:args]
    ensure
      ActiveSupport::Notifications.unsubscribe "process.push_notification"
    end
  end
end
