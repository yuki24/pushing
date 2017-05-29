module ApnTcpTestCases
  def test_actually_push_notification
    assert_nothing_raised do
      WeatherNotifier.weather_update(apn: true).deliver_now!
    end
  end
end
