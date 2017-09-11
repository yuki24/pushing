# frozen-string-literal: true

require 'active_support/configurable'
require 'active_support/core_ext/hash/keys'

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
      attr_reader :payload, :device_token, :environment

      EMPTY_HASH = {}.freeze

      def self.should_render?(options)
        options.is_a?(Hash) ? options[:device_token].present? : options.present?
      end

      def initialize(payload, options, config = EMPTY_HASH)
        @payload     = payload
        @environment = config[:environment]
        @headers     = config[:default_headers] || {}

        if config[:topic]
          ActiveSupport::Deprecation.warn "`config.apn.topic' is deprecated and will be removed in 0.3.0. " \
                                          "Please use `config.apn.default_headers' instead:\n\n" \
                                          "  config.apn.default_headers = {\n" \
                                          "    apns_topic: '#{config[:topic]}'\n" \
                                          "  }", caller

          @headers['apns-topic'] ||= config[:topic]
        end

        if options.is_a?(String)
          @device_token = options
        elsif options.is_a?(Hash)
          @device_token = options[:device_token]
          @environment  = options[:environment] || @environment
          @headers      = @headers.merge(options[:headers] || EMPTY_HASH)
        else
          raise TypeError, "The :apn key only takes a device token as a string or a hash that has `device_token: \"...\"'.")
        end

        # raise("APNs environment is required.")  if @environment.nil?
        # raise("APNs device token is required.") if @device_token.nil?

        @environment = @environment.to_sym
      end

      def recipients
        Array("#{@environment}/#{@device_token}")
      end

      def headers
        @normalized_headers ||= begin
                                  h = @headers.stringify_keys.transform_keys!(&:dasherize)

                                  {
                                    authorization:      h['authorization'],
                                    'apns-id':          h['apns-id']          || h['id'],
                                    'apns-expiration':  h['apns-expiration']  || h['expiration'],
                                    'apns-priority':    h['apns-priority']    || h['priority'],
                                    'apns-topic':       h['apns-topic']       || h['topic'],
                                    'apns-collapse-id': h['apns-collapse-id'] || h['collapse-id'],
                                  }
                                end
      end
    end

    class FcmPayload
      attr_reader :payload

      def self.should_render?(options)
        options.present?
      end

      def initialize(payload, *)
        @payload = payload
      end

      def recipients
        Array(payload[:to] || payload[:registration_ids])
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
