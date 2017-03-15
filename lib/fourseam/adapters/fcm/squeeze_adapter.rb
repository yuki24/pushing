require 'squeeze'

module Fourseam
  module Adapters
    class SqueezeAdapter
      def initialize(fcm_settings)
        @server_key = fcm_settings.server_key
      end

      def push!(notification)
        response = client.push(JSON.parse(notification.fcm.payload))

        {
          headers: response.headers.transform_values(&:join),
          json:    response.json
        }
      end

      private

      def client
        @client ||= Squeeze.build(@server_key)
      end
    end
  end
end
