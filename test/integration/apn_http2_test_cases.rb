module ApnHttp2TestCases
  def test_actually_push_notification
    responses = WeatherNotifier.weather_update(apn: true).deliver_now!
  end

  def test_raise_error_on_error_response
    assert_nothing_raised do
      NotifierWithRescueHandler.apn.deliver_now!
    end

    response = NotifierWithRescueHandler.last_response_from_apn
    assert_equal '400', response.status
  end
end
