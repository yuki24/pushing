require 'integration/test_helper'
require 'integration/apn_tcp_test_cases'

class HoustonIntegrationTest < ActiveSupport::TestCase
  include ApnTcpTestCases

  setup do
    Pushing::Platforms.config.apn.adapter = :houston
    Pushing::Platforms.config.apn.certificate_path = File.join(File.expand_path("./"), ENV.fetch('APN_TEST_CERTIFICATE_PATH'))
  end

  private

  def adapter
    'houston'
  end
end
