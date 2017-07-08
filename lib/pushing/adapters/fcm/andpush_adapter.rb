# frozen-string-literal: true

require 'andpush'
require 'active_support/core_ext/hash/transform_values'

module Pushing
  module Adapters
    class AndpushAdapter
      attr_reader :server_key

      def initialize(fcm_settings)
        @server_key = fcm_settings.server_key
      end

      def push!(notification)
        FcmResponse.new(client.push(notification.payload))
      rescue => e
        response = e.respond_to?(:response) ? FcmResponse.new(e.response) : nil
        error    = Pushing::FcmDeliveryError.new("Error while trying to send push notification: #{e.message}", response, notification)

        raise error, error.message, e.backtrace
      end

      private

      def client
        @client ||= Andpush.build(server_key)
      end

      class FcmResponse < SimpleDelegator
        def json
          @json ||= __getobj__.json
        end

        def code
          __getobj__.code.to_i
        end

        def headers
          __getobj__.headers.transform_values {|value| value.join(", ") }
        end
      end

      private_constant :FcmResponse
    end
  end
end
