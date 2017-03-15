require 'test_helper'
require "action_dispatch"
require "active_support/time"

require 'notifiers/weather_notifier'

class BaseTest < ActiveSupport::TestCase
  setup do
    Fourseam::Base.delivery_method = :default
    Fourseam::Base.fcm.adapter = :robo_msg
    Fourseam::Base.fcm.server_key = ENV.fetch('FCM_TEST_SERVER_KEY')
  end

  test "actually push the notification" do
    WeatherNotifier.weather_update.deliver_now!
  end
end
