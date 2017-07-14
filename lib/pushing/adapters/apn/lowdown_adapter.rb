# frozen-string-literal: true

require 'json'

module Pushing
  module Adapters
    class LowdownAdapter
      attr_reader :environment, :topic, :clients

      def initialize(apn_settings)
        @environment = apn_settings.environment.to_sym
        @topic       = apn_settings.topic

        # Don't load lowdown earlier as it may load Celluloid (and start it)
        # before daemonizing the workers spun up by a gem (e,g, delayed_job).
        require 'lowdown' unless defined?(Lodwown)

        cert = File.read(apn_settings.certificate_path)
        @clients = {
          development: Lowdown::Client.production(false, certificate: cert, keep_alive: true),
          production: Lowdown::Client.production(true, certificate: cert, keep_alive: true)
        }
      end

      def push!(notification)
        lowdown_notification = Lowdown::Notification.new(token: notification.device_token)
        lowdown_notification.payload = notification.payload
        lowdown_notification.topic   = topic

        response = nil
        clients[notification.environment || environment].group do |group|
          group.send_notification(lowdown_notification) do |_response|
            response = _response
          end
        end

        raise response.raw_body if !response.success?
        ApnResponse.new(response)
      rescue => cause
        response = response ? ApnResponse.new(response) : nil
        error    = Pushing::ApnDeliveryError.new("Error while trying to send push notification: #{cause.message}", response, notification)

        raise error, error.message, cause.backtrace
      end

      class ApnResponse < SimpleDelegator
        def code
          __getobj__.status
        end

        def json
          @json ||= JSON.parse(__getobj__.raw_body, symbolize_names: true) if __getobj__.raw_body
        end
      end

      private_constant :ApnResponse
    end
  end
end
