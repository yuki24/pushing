require 'integration/test_helper'
require 'integration/apn_http2_test_cases'

class ApnoticIntegrationTest < ActiveSupport::TestCase
  include ApnHttp2TestCases

  setup do
    Pushing::Platforms.config.apn.adapter = :apnotic
  end

  private

  def adapter
    'apnotic'
  end
end

