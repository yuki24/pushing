require 'test_helper'
require "action_dispatch"
require "active_support/time"

require 'notifiers/weather_notifier'

class IntegrationTest < ActiveSupport::TestCase
  setup do
    Fourseam::Base.logger = Logger.new(STDOUT)

    Fourseam::Platforms.configure do |config|
      config.fcm.server_key = ENV.fetch('FCM_TEST_SERVER_KEY')

      config.apn.environment          = :development
      config.apn.certificate_path     = ENV.fetch('APN_TEST_CERTIFICATE_PATH')
      config.apn.certificate_password = ENV.fetch('APN_TEST_CERTIFICATE_PASSWORD')
      config.apn.topic                = ENV.fetch('APN_TEST_TOPIC')
    end
  end

  test "actually push the notification with houston" do
    Fourseam::Platforms.config.apn.adapter = :houston

    WeatherNotifier.weather_update(apn: true).deliver_now!
  end

  test "actually push the notification with apnotic" do
    Fourseam::Platforms.config.apn.adapter = :apnotic

    WeatherNotifier.weather_update(apn: true).deliver_now!
  end

  test "actually push the notification with robo_msg" do
    Fourseam::Platforms.config.fcm.adapter = :robo_msg

    WeatherNotifier.weather_update(fcm: true).deliver_now!
  end
end
