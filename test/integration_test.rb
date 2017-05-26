require 'test_helper'
require 'webmock/minitest'

require 'notifiers/weather_notifier'
require 'notifiers/notifier_with_observer'
require 'notifiers/notifier_with_rescue_handler'

class IntegrationTest < ActiveSupport::TestCase
  setup do
    WebMock.allow_net_connect!
    Pushing::Base.logger = Logger.new(STDOUT)
    Pushing::Platforms.configure do |config|
      config.fcm.server_key = ENV.fetch('FCM_TEST_SERVER_KEY')

      config.apn.environment          = :development
      config.apn.certificate_path     = ENV.fetch('APN_TEST_CERTIFICATE_PATH')
      config.apn.certificate_password = ENV.fetch('APN_TEST_CERTIFICATE_PASSWORD')
      config.apn.topic                = ENV.fetch('APN_TEST_TOPIC')
    end
  end

  test "actually push the notification with houston" do
    Pushing::Platforms.config.apn.adapter = :houston

    WeatherNotifier.weather_update(apn: true).deliver_now!
  end

  test "actually push the notification with apnotic" do
    Pushing::Platforms.config.apn.adapter = :apnotic

    WeatherNotifier.weather_update(apn: true).deliver_now!
  end

  test "raise an error on an error response with apnotic" do
    Pushing::Platforms.config.apn.adapter = :apnotic

    assert_nothing_raised do
      NotifierWithRescueHandler.apn.deliver_now!
    end

    response = NotifierWithRescueHandler.last_response_from_apn
    assert_equal '400', response.status
  end

  test "actually push the notification with robo_msg" do
    Pushing::Platforms.config.fcm.adapter = :robo_msg

    WeatherNotifier.weather_update(fcm: true).deliver_now!
  end

  test "Observer can observe responses from FCM" do
    Pushing::Platforms.config.fcm.adapter = :robo_msg
    stub_request(:post, "https://fcm.googleapis.com/fcm/send").to_return(
      status: 200,
      body: {
        multicast_id: 216,
        success: 3,
        failure: 3,
        canonical_ids: 1,
        results: [
          { message_id: "1:0408" },
          { error: "Unavailable" },
          { error: "InvalidRegistration" },
          { message_id: "1:1516" },
          { message_id: "1:2342", registration_id: "32" },
          { error: "NotRegistered"}
        ]
      }.to_json
    )

    NotifierWithObserver.weather_update(fcm: true).deliver_now!

    assert_equal ["32"], NotifierWithObserver::FcmTokenHandler.canonical_ids
  end

  test "raise an error on an error response with robo_msg" do
    stub_request(:post, "https://fcm.googleapis.com/fcm/send").to_return(status: 400)
    Pushing::Platforms.config.fcm.adapter = :robo_msg

    assert_nothing_raised do
      NotifierWithRescueHandler.fcm.deliver_now!
    end

    response = NotifierWithRescueHandler.last_response_from_fcm
    assert_equal '400', response.code
  end
end
