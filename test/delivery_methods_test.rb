require 'test_helper'
require "set"
require "action_dispatch"
require "active_support/time"

class DefaultDeliveryMethodTest < ActiveSupport::TestCase
  setup do
    Fourseam::Base.fcm.server_key = "server-key"
  end

  test "default APN settings" do
    fcm_settings = Fourseam::Base.fcm

    assert_equal :robo_msg,    fcm_settings.adapter
    assert_equal "server-key", fcm_settings.server_key
  end
end
