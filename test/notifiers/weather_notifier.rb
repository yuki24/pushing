class WeatherNotifier < Fourseam::Base
  def weather_update(apn: false, fcm: false)
    push apn: apn && ENV.fetch('APN_TEST_DEVICE_TOKEN'), fcm: fcm
  end
end
