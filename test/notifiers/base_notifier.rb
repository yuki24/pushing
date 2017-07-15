class BaseNotifier < Pushing::Base
  def welcome(hash = {})
    push apn: 'device-token', fcm: true
  end

  def missing_apn_template
    push apn: 'device-token'
  end

  def missing_fcm_template
    push fcm: true
  end

  def with_apn_template
    push apn: 'device-token'
  end

  def with_no_apn_device_token
    push apn: { device_token: nil }
  end

  def with_fcm_template
    push fcm: true
  end

  def without_push_call
  end

  def with_nil_as_return_value
    push apn: 'device-token'
    nil
  end
end

