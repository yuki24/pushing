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
    Base.configure(&block)
    Base.config.each { |k, v| Base.public_send("#{k}=", v) if Base.respond_to?("#{k}=") }
  end

  def self.config
    Base.config
  end
end

if defined?(Rails)
  require 'pushing/railtie'
end
