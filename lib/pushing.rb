require "active_support/dependencies/autoload"
require "pushing/version"

module Pushing
  extend ::ActiveSupport::Autoload

  autoload :Adapters
  autoload :Base
  autoload :DeliveryJob
  autoload :NotificationDelivery
end

if defined?(Rails)
  require 'pushing/railtie'
end
