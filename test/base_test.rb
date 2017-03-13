require 'test_helper'
require "set"
require "action_dispatch"
require "active_support/time"

require 'notifiers/base_notifier'

class BaseTest < ActiveSupport::TestCase
  test "method call to mail does not raise error" do
    assert_nothing_raised { BaseNotifier.welcome }
  end
end
