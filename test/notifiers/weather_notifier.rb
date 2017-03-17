class WeatherNotifier < Fourseam::Base
  def weather_update(hash = {})
    push apn: ENV.fetch('APN_TEST_DEVICE_TOKEN'), fcm: true
  end
end
