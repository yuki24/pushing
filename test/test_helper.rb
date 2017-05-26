$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'active_support/core_ext/kernel/reporting'
require 'pushing'

# These are the normal settings that will be set up by Railties
# TODO: Have these tests support other combinations of these values
silence_warnings do
  Encoding.default_internal = "UTF-8"
  Encoding.default_external = "UTF-8"
end

require 'active_support/testing/autorun'
require 'minitest/pride'
require 'pry'
require 'pry-byebug' if RUBY_ENGINE == 'ruby'

# Emulate AV railtie
require 'action_view'
Pushing::Base.include(ActionView::Layouts)

# Show backtraces for deprecated behavior for quicker cleanup.
ActiveSupport::Deprecation.debug = true

FIXTURE_LOAD_PATH = File.expand_path('fixtures', File.dirname(__FILE__))
Pushing::Base.view_paths = FIXTURE_LOAD_PATH

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

Pushing::Platforms.config.apn.adapter = :test
Pushing::Platforms.config.fcm.adapter = :test
