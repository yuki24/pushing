require 'andpush'

module Pushing
  module Adapters
    class AndpushAdapter
      def initialize(fcm_settings)
        @server_key = fcm_settings.server_key
      end

      def push!(notification)
        client.push(notification.payload)
      rescue => e
        raise Pushing::FcmDeliveryError.new("Error while trying to send push notification: #{e.message}", e.response)
      end

      private

      def client
        @client ||= Andpush.build(@server_key)
      end
    end
  end
end
