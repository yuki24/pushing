module ApnHttp2TestCases
  def test_actually_push_notification
    responses = MaintainerNotifier.build_result(adapter, apn: true).deliver_now!
    response  = responses.first

    assert_equal '200', response.status
  end

  def test_notifier_raises_exception_on_http_client_error
    error = assert_raises Pushing::ApnDeliveryError do
      MaintainerNotifier.build_result(adapter, apn: 'bad-token').deliver_now!
    end

    assert_equal '400', error.response.status
  end

  def test_raise_error_on_error_response
    assert_nothing_raised do
      NotifierWithRescueHandler.apn.deliver_now!
    end

    response = NotifierWithRescueHandler.last_response_from_apn
    assert_equal '400', response.status
  end

  def adapter
    raise NotImplementedError
  end
end
