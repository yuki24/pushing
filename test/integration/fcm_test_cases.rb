module FcmTestCases
  def test_actually_push_notification
    responses = WeatherNotifier.weather_update(fcm: true).deliver_now!
    response  = responses.first

    assert_equal '200', response.code
  end

  def test_observer_can_observe_responses_from_fcm
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

  def test_notifier_raises_exception_on_http_client_error
    stub_request(:post, "https://fcm.googleapis.com/fcm/send").to_return(status: 400)

    error = assert_raises Pushing::FcmDeliveryError do
      WeatherNotifier.weather_update(fcm: true).deliver_now!
    end

    assert_equal '400', error.response.code
  end

  def test_notifier_can_rescue_error_on_error_response
    stub_request(:post, "https://fcm.googleapis.com/fcm/send").to_return(status: 400)

    assert_nothing_raised do
      NotifierWithRescueHandler.fcm.deliver_now!
    end

    response = NotifierWithRescueHandler.last_response_from_fcm
    assert_equal '400', response.code
  end
end
