require 'houston'

module Pushing
  module Adapters
    class HoustonAdapter
      def initialize(apn_settings)
        @certificate_path = apn_settings.certificate_path
        @environment      = apn_settings.environment
      end

      def push!(notification)
        payload      = notification.payload
        aps          = payload.delete(:aps)
        aps[:device] = notification.device_token

        houston_notification = Houston::Notification.new(payload.merge(aps))
        client.push(houston_notification)
      end

      private

      def client
        @client ||= begin
                      apn = Houston::Client.public_send(@environment)
                      apn.certificate = certificate
                      apn
                    end
      end

      def certificate
        @certificate ||= File.read(@certificate_path)
      end
    end
  end
end
