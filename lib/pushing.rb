require "abstract_controller"
require "pushing/version"

module Pushing
  extend ::ActiveSupport::Autoload

  autoload :Adapters
  autoload :Base
  autoload :DeliveryJob
  autoload :NotificationDelivery
  autoload :NotificationHelper
  autoload :Platforms
end

if defined?(Rails)
  require 'pushing/railtie'
end
