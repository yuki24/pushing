require 'integration/test_helper'
require 'integration/apn_http2_test_cases'

class ApnoticIntegrationForCertificateConnectionTest < ActiveSupport::TestCase
  include ApnHttp2TestCases

  setup do
    Pushing::Platforms.config.apn.adapter = :apnotic
    Pushing::Platforms.config.apn.connection_scheme = :certificate
    Pushing::Platforms.config.apn.certificate_path  = File.join(File.expand_path("./"), ENV.fetch('APN_TEST_CERTIFICATE_PATH'))
  end

  private

  def adapter
    'apnotic'
  end
end

class ApnoticIntegrationTestForJwtConnection < ActiveSupport::TestCase
  include ApnHttp2TestCases

  setup do
    Pushing::Platforms.config.apn.adapter = :apnotic
    Pushing::Platforms.config.apn.connection_scheme = :token
    Pushing::Platforms.config.apn.certificate_path  = File.join(File.expand_path("./"), ENV.fetch('APN_TEST_AUTH_KEY_PATH'))
    Pushing::Platforms.config.apn.key_id = ENV['APN_TEST_KEY_ID']
    Pushing::Platforms.config.apn.team_id = ENV['APN_TEST_TEAM_ID']
  end

  private

  def adapter
    'apnotic'
  end
end
