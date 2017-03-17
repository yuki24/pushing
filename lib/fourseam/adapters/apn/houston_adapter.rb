require 'houston'

module Fourseam
  module Adapters
    class HoustonAdapter
      def initialize(apn_settings)
        @certificate = apn_settings.certificate
        @environment = apn_settings.environment
      end

      def push!(notification)
        payload      = notification.apn.payload
        aps          = payload.delete(:aps)
        aps[:device] = notification.apn.device_token

        houston_notification = Houston::Notification.new(payload.merge(aps))
        client.push(houston_notification)
      end

      private

      def client
        @client ||= begin
                      apn = Houston::Client.public_send(@environment)
                      apn.certificate = @certificate
                      apn
                    end
      end
    end
  end
end
