module ApnHttp2TestCases
  def setup
    super
    Pushing::Adapters.const_get(:ADAPTER_INSTANCES).clear
  end

  def test_actually_push_notification
    responses = MaintainerNotifier.build_result(adapter, apn: true).deliver_now!
    response  = responses.first

    assert_equal 200, response.code
    assert_nil response.json
    assert_match /\A\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\z/, response.headers["apns-id"]
  end

  def test_push_notification_with_custom_config
    # Set the wrong topic/environment to make sure you can override these on the fly
    Pushing::Platforms.config.apn.topic = 'wrong.topicname.com'
    Pushing::Platforms.config.apn.environment = :production

    apns_id = SecureRandom.uuid
    headers = {
      apns_id:          apns_id,
      apns_expiration:  1.hour.from_now,
      apns_priority:    5,
      apns_topic:       ENV.fetch('APN_TEST_TOPIC'),
      apns_collapse_id: 'pushing-testing'
    }

    responses = MaintainerNotifier.build_result_with_custom_apn_config(adapter, :development, headers).deliver_now!
    response  = responses.first

    assert_equal 200, response.code
    assert_nil response.json

    if adapter == 'lowdown'
      assert_match /\A\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\z/, response.headers["apns-id"]
    else
      assert_match apns_id, response.headers["apns-id"]
    end
  ensure
    Pushing::Platforms.config.apn.topic = ENV.fetch('APN_TEST_TOPIC')
    Pushing::Platforms.config.apn.environment = :development
  end

  def test_notifier_raises_exception_on_http_client_error
    error = assert_raises Pushing::ApnDeliveryError do
      MaintainerNotifier.build_result(adapter, apn: 'bad-token').deliver_now!
    end

    assert_equal 400, error.response.code
    assert_equal "BadDeviceToken", error.response.json[:reason]
    assert_equal ['bad-token'], error.notification.recipients
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
