require "abstract_controller"
require "fourseam/version"

module Fourseam
  extend ::ActiveSupport::Autoload

  autoload :Adapters
  autoload :Base
  autoload :DeliveryJob
  autoload :NotificationDelivery
  autoload :NotificationHelper
  autoload :Platforms
end

if defined?(Rails)
  require 'fourseam/railtie'
end
