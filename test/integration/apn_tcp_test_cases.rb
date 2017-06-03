module ApnTcpTestCases
  def test_actually_push_notification
    assert_nothing_raised do
      MaintainerNotifier.build_result(adapter, apn: true).deliver_now!
    end
  end

  def adapter
    raise NotImplementedError
  end
end
