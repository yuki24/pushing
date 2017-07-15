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
    Pushing::Platforms.config.apn.topic = 'wrong.topicname.com'
    Pushing::Platforms.config.apn.environment = :production

    assert_nothing_raised do
      MaintainerNotifier.build_result_with_custom_apn_config(adapter, :development, {}).deliver_now!
    end
  ensure
    Pushing::Platforms.config.apn.topic = ENV.fetch('APN_TEST_TOPIC')
    Pushing::Platforms.config.apn.environment = :development
  end

  def adapter
    raise NotImplementedError
  end
end
