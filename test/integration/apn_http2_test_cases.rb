module ApnHttp2TestCases
  def test_actually_push_notification
    responses = MaintainerNotifier.build_result(adapter, apn: true).deliver_now!
    response  = responses.first

    assert_equal 200, response.code
    assert_equal nil, response.json
    assert_match /\A\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\z/, response.headers["apns-id"]
  end

  def test_notifier_raises_exception_on_http_client_error
    error = assert_raises Pushing::ApnDeliveryError do
      MaintainerNotifier.build_result(adapter, apn: 'bad-token').deliver_now!
    end

    assert_equal 400, error.response.code
    assert_equal "BadDeviceToken", error.response.json[:reason]
  end

  def test_raise_error_on_error_response
    assert_nothing_raised do
      NotifierWithRescueHandler.apn.deliver_now!
    end

    response = NotifierWithRescueHandler.last_response_from_apn
    assert_equal 400, response.code
  end

  def adapter
    raise NotImplementedError
  end
end
