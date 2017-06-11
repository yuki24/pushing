# frozen-string-literal: true

require 'andpush'

module Pushing
  module Adapters
    class AndpushAdapter
      def initialize(fcm_settings)
        @server_key = fcm_settings.server_key
      end

      def push!(notification)
        FcmResponse.new(self.class.client(@server_key).push(notification.payload))
      rescue => e
        raise Pushing::FcmDeliveryError.new("Error while trying to send push notification: #{e.message}", FcmResponse.new(e.response))
      end

      @@semaphore = Mutex.new

      def self.client(server_key)
        @client || @@semaphore.synchronize { @client = Andpush.build(server_key) }
      end

      class FcmResponse < SimpleDelegator
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
