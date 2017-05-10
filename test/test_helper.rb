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
require 'active_support/testing/method_call_assertions'
require 'minitest/pride'
require 'fourseam'
require 'pry-byebug'

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

class ActiveSupport::TestCase
  include ActiveSupport::Testing::MethodCallAssertions
end
