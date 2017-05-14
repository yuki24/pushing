$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'active_support/core_ext/kernel/reporting'

# These are the normal settings that will be set up by Railties
# TODO: Have these tests support other combinations of these values
silence_warnings do
  Encoding.default_internal = "UTF-8"
  Encoding.default_external = "UTF-8"
end

module Rails
  def self.root
    File.expand_path('../', File.dirname(__FILE__))
  end
end

require 'active_support/testing/autorun'
require 'minitest/pride'
require 'fourseam'
require 'pry'
require 'pry-byebug' if RUBY_ENGINE == 'ruby'

# Emulate AV railtie
require 'action_view'
Fourseam::Base.include(ActionView::Layouts)

# Show backtraces for deprecated behavior for quicker cleanup.
ActiveSupport::Deprecation.debug = true

# Disable available locale checks to avoid warnings running the test suite.
I18n.enforce_available_locales = false

FIXTURE_LOAD_PATH = File.expand_path('fixtures', File.dirname(__FILE__))
Fourseam::Base.view_paths = FIXTURE_LOAD_PATH

require "rails"
require 'jbuilder'
require 'jbuilder/jbuilder_template'

ActionView::Template.register_template_handler :jbuilder, JbuilderHandler

begin
  require 'active_support/testing/method_call_assertions'
  ActiveSupport::TestCase.include ActiveSupport::Testing::MethodCallAssertions
rescue LoadError
  # Rails 4.2 doesn't come with ActiveSupport::Testing::MethodCallAssertions
  require 'backport/method_call_assertions'
  ActiveSupport::TestCase.include MethodCallAssertions

  # FIXME: we have tests that depend on run order, we should fix that and
  # remove this method call.
  require 'active_support/test_case'
  ActiveSupport::TestCase.test_order = :sorted
end

Fourseam::Base.config.apn.adapter = :test
Fourseam::Base.config.fcm.adapter = :test
