require 'integration/test_helper'
require 'integration/fcm_test_cases'

class FcmAdapterIntegrationTest < ActiveSupport::TestCase
  include FcmTestCases

  setup do
    Pushing::Platforms.config.fcm.adapter = :fcm_gem
  end

  private

  def adapter
    'fcm'
  end
end

