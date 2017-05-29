require 'integration/test_helper'
require 'integration/apn_tcp_test_cases'

class HoustonIntegrationTest < ActiveSupport::TestCase
  include ApnTcpTestCases

  setup do
    Pushing::Platforms.config.apn.adapter = :houston
  end
end
