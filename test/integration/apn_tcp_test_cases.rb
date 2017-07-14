module ApnTcpTestCases
  def test_actually_push_notification
    assert_nothing_raised do
      MaintainerNotifier.build_result(adapter, apn: true).deliver_now!
    end
  end

  def test_actually_push_notification_with_custom_config
    Pushing::Adapters.const_get(:ADAPTER_INSTANCES).clear
    Pushing::Platforms.config.apn.environment = :production

    assert_nothing_raised do
      MaintainerNotifier.build_result_with_custom_apn_config(adapter).deliver_now!
    end
  ensure
    Pushing::Platforms.config.apn.environment = :development
  end

  def adapter
    raise NotImplementedError
  end
end
