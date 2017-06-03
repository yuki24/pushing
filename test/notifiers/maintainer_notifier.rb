class MaintainerNotifier < Pushing::Base
  def build_result(adapter, apn: false, fcm: false)
    @adapter = adapter
    @ruby_version = RUBY_DESCRIPTION
    @rails_version = Rails::VERSION::STRING

    push apn: apn && ENV.fetch('APN_TEST_DEVICE_TOKEN'), fcm: fcm
  end
end
