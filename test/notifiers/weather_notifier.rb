class WeatherNotifier < Fourseam::Base
  def weather_update(hash = {})
    push apn: 'device-token', fcm: true
  end
end
