require 'integration/test_helper'
require 'integration/fcm_test_cases'

class AndpushIntegrationTest < ActiveSupport::TestCase
  include FcmTestCases

  setup do
    Pushing::Platforms.config.fcm.adapter = :andpush
  end
end

