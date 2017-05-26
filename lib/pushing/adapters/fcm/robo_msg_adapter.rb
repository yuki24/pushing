require 'robo_msg'

module Pushing
  module Adapters
    class RoboMsgAdapter
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
        @client ||= RoboMsg.build(@server_key)
      end
    end
  end
end
