require 'robo_msg'

module Fourseam
  module Adapters
    class RoboMsgAdapter
      def initialize(fcm_settings)
        @server_key = fcm_settings.server_key
      end

      def push!(notification)
        response = client.push(notification.payload)

        {
          headers: response.headers.transform_values(&:join),
          json:    response.json
        }
      end

      private

      def client
        @client ||= RoboMsg.build(@server_key)
      end
    end
  end
end
