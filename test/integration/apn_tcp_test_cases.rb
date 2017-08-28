module ApnTcpTestCases
  def setup
    super
    Pushing::Adapters.const_get(:ADAPTER_INSTANCES).clear
  end

  def test_actually_push_notification
    assert_nothing_raised do
      MaintainerNotifier.build_result(adapter, apn: true).deliver_now!
    end
  end

  def test_actually_push_notification_with_custom_config
    # Set the wrong topic/environment to make sure you can override these on the fly
    Pushing::Platforms.config.apn.environment = :production
    Pushing::Platforms.config.apn.default_headers = {
      apns_topic: 'wrong.topicname.com'
    }

    assert_nothing_raised do
      MaintainerNotifier.build_result_with_custom_apn_config(adapter, :development, {}).deliver_now!
    end
  ensure
    Pushing::Platforms.config.apn.environment = :development
    Pushing::Platforms.config.apn.default_headers = {
      apns_topic: ENV.fetch('APN_TEST_TOPIC')
    }
  end

  def adapter
    raise NotImplementedError
  end
end
