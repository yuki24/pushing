require 'integration/test_helper'
require 'integration/apn_http2_test_cases'

class LowdownTest < ActiveSupport::TestCase
  include ApnHttp2TestCases

  setup do
    Pushing::Platforms.config.apn.adapter = :lowdown
  end

  private

  def adapter
    'lowdown'
  end
end
