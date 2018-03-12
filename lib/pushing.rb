require "active_support/dependencies/autoload"
require "pushing/version"

module Pushing
  extend ::ActiveSupport::Autoload

  autoload :Adapters
  autoload :Base
  autoload :DeliveryJob
  autoload :NotificationDelivery
  autoload :Platforms

  def self.configure(&block)
    Base.config.default_url_options = Base.default_url_options
    Base.configure(&block)
  end

  def self.config
    Base.config
  end
end

if defined?(Rails)
  require 'pushing/railtie'
end
