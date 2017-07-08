# frozen-string-literal: true

require 'active_support/configurable'

module Pushing
  module Platforms
    include ActiveSupport::Configurable

    config.apn = ActiveSupport::OrderedOptions.new
    config.fcm = ActiveSupport::OrderedOptions.new

    class << self
      def lookup(platform_name)
        const_get(:"#{platform_name.capitalize}Payload")
      end
    end

    class ApnPayload
      attr_reader :payload, :device_token

      def initialize(payload, device_token)
        @payload, @device_token = payload, device_token
      end

      def recipients
        Array(@device_token) # TODO: make sure device tokens can be an array
      end
    end

    class FcmPayload
      attr_reader :payload

      def initialize(payload, *)
        @payload = payload
      end

      def recipients
        # TODO: make sure the :to key can hold an array
        Array(payload['to'] || payload['registration_ids'])
      end
    end
  end

  class DeliveryError < RuntimeError
    attr_reader :response, :notification

    def initialize(message, response = nil, notification = nil)
      super(message)
      @response = response
      @notification = notification
    end
  end

  class ApnDeliveryError < DeliveryError
  end

  class FcmDeliveryError < DeliveryError
  end
end
