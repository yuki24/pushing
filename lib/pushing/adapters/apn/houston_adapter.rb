require 'houston'
require 'active_support/core_ext/hash/keys'

module Pushing
  module Adapters
    class HoustonAdapter
      attr_reader :certificate_path, :environment, :client

      def initialize(apn_settings)
        @certificate_path = apn_settings.certificate_path
        @environment      = apn_settings.environment

        @client = {
          production: Houston::Client.production,
          development: Houston::Client.development
        }
        @client[:production].certificate = @client[:development].certificate = File.read(certificate_path)
      end

      def push!(notification)
        payload      = notification.payload.deep_symbolize_keys
        aps          = payload.delete(:aps)
        aps[:device] = notification.device_token

        houston_notification = Houston::Notification.new(payload.merge(aps))
        client[notification.environment || environment].push(houston_notification)
      rescue => cause
        error = Pushing::ApnDeliveryError.new("Error while trying to send push notification: #{cause.message}", nil, notification)

        raise error, error.message, cause.backtrace
      end
    end
  end
end
