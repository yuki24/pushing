require 'houston'
require 'active_support/core_ext/hash/keys'

module Pushing
  module Adapters
    class HoustonAdapter
      attr_reader :certificate_path, :environment

      def initialize(apn_settings)
        @certificate_path = apn_settings.certificate_path
        @environment      = apn_settings.environment
      end

      def push!(notification)
        payload      = notification.payload.deep_symbolize_keys
        aps          = payload.delete(:aps)
        aps[:device] = notification.device_token

        houston_notification = Houston::Notification.new(payload.merge(aps))
        client.push(houston_notification)
      rescue => cause
        error = Pushing::ApnDeliveryError.new("Error while trying to send push notification: #{cause.message}")

        raise error, error.message, cause.backtrace
      end

      private

      def client
        @client ||= begin
                      apn = Houston::Client.public_send(environment)
                      apn.certificate = certificate
                      apn
                    end
      end

      def certificate
        @certificate ||= File.read(certificate_path)
      end
    end
  end
end
