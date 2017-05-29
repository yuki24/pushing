require 'integration/test_helper'
require 'integration/fcm_test_cases'

class RoboMsgIntegrationTest < ActiveSupport::TestCase
  include FcmTestCases

  setup do
    Pushing::Platforms.config.fcm.adapter = :robo_msg
  end
end

