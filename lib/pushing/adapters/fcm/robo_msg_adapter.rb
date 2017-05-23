require 'robo_msg'

module Pushing
  module Adapters
    class RoboMsgAdapter
      def initialize(fcm_settings)
        @server_key = fcm_settings.server_key
      end

      def push!(notification)
        client.push(notification.payload)
      end

      private

      def client
        @client ||= RoboMsg.build(@server_key)
      end
    end
  end
end
