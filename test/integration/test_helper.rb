require 'test_helper'
require 'webmock/minitest'

require 'notifiers/maintainer_notifier'
require 'notifiers/notifier_with_rescue_handler'

WebMock.allow_net_connect!

Pushing::Base.logger = Logger.new(STDOUT)
Pushing::Platforms.configure do |config|
  config.fcm.server_key = ENV.fetch('FCM_TEST_SERVER_KEY')

  config.apn.environment          = :development
  config.apn.certificate_path     = File.join(File.expand_path("./"), ENV.fetch('APN_TEST_CERTIFICATE_PATH'))
  config.apn.certificate_password = ENV.fetch('APN_TEST_CERTIFICATE_PASSWORD')
  config.apn.default_headers      = {
    apns_topic: ENV.fetch('APN_TEST_TOPIC')
  }
end
