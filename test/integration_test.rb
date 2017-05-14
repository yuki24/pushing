require 'test_helper'
require "action_dispatch"
require "active_support/time"

require 'notifiers/weather_notifier'

class BaseTest < ActiveSupport::TestCase
  setup do
    Fourseam::Base.logger               = Logger.new(STDOUT)
    Fourseam::Base.apn.certificate_path = ENV.fetch('APN_TEST_CERTIFICATE_PATH')
    Fourseam::Base.fcm.server_key       = ENV.fetch('FCM_TEST_SERVER_KEY')
  end

  test "actually push the notification with houston" do
    Fourseam::Base.apn.adapter = :houston

    WeatherNotifier.weather_update(apn: true).deliver_now!
  end

  test "actually push the notification with apnotic" do
    Fourseam::Base.apn.adapter              = :apnotic
    Fourseam::Base.apn.certificate_path     = ENV.fetch('APN_TEST_CERTIFICATE_PATH')
    Fourseam::Base.apn.certificate_password = ENV.fetch('APN_TEST_CERTIFICATE_PASSWORD')
    Fourseam::Base.apn.topic                = ENV.fetch('APN_TEST_TOPIC')
    Fourseam::Base.apn.environment          = :development

    WeatherNotifier.weather_update(apn: true).deliver_now!
  end

  test "actually push the notification with robo_msg" do
    Fourseam::Base.fcm.adapter = :robo_msg

    WeatherNotifier.weather_update(fcm: true).deliver_now!
  end
end
