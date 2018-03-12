require 'integration/test_helper'
require 'integration/fcm_test_cases'

class AndpushIntegrationTest < ActiveSupport::TestCase
  include FcmTestCases

  setup do
    Pushing.config.fcm.adapter = :andpush
  end

  private

  def adapter
    'andpush'
  end
end

