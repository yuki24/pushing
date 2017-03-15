require 'fourseam/delivery_methods/delivery_delegator'
require 'fourseam/delivery_methods/test_notifier'

module Fourseam
  module DeliveryMethods
    extend ActiveSupport::Concern

    included do
      class_attribute :delivery_methods, :delivery_method

      cattr_accessor :deliver_later_queue_name
      self.deliver_later_queue_name = :notifiers

      self.delivery_methods = {}.freeze
      self.delivery_method  = :default

      add_delivery_method :default, Fourseam::DeliveryDelegator
      add_delivery_method :test,    Fourseam::TestNotifier
    end

    module ClassMethods
      delegate :deliveries, :deliveries=, to: Fourseam::TestNotifier

      def add_delivery_method(symbol, klass, default_options = {})
        class_attribute(:"#{symbol}_settings") unless respond_to?(:"#{symbol}_settings")
        send(:"#{symbol}_settings=", default_options)
        self.delivery_methods = delivery_methods.merge(symbol.to_sym => klass).freeze
      end

      def wrap_delivery_behavior(notification, options = nil) # :nodoc:
        method ||= delivery_method
        notification.delivery_handler = self

        case method
        when NilClass
          raise "Delivery method cannot be nil"
        when Symbol
          if klass = delivery_methods[method]
            platform_settings = platforms.map {|platform| public_send(platform) }
            notification.delivery_method = klass.new(platform_settings, (send(:"#{method}_settings") || {}).merge(options || {}))
          else
            raise "Invalid delivery method #{method.inspect}"
          end
        else
          notification.delivery_method = method
        end
      end
    end
  end
end
