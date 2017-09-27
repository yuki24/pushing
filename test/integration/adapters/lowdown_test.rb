require 'integration/test_helper'
require 'integration/apn_http2_test_cases'

class LowdownTest < ActiveSupport::TestCase
  include ApnHttp2TestCases

  setup do
    Pushing::Platforms.config.apn.adapter = :lowdown
    Pushing::Platforms.config.apn.connection_scheme = :certificate
    Pushing::Platforms.config.apn.certificate_path = File.join(File.expand_path("./"), ENV.fetch('APN_TEST_CERTIFICATE_PATH'))
  end

  private

  def adapter
    'lowdown'
  end
end
