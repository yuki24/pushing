# frozen-string-literal: true

require 'json'
require 'active_support/string_inquirer'

module Pushing
  module Adapters
    class LowdownAdapter
      @@clients   = {}
      @@semaphore = Mutex.new

      def initialize(apn_settings)
        @certificate_path = apn_settings.certificate_path
        @environment      = ActiveSupport::StringInquirer.new(apn_settings.environment.to_s)
        @topic            = apn_settings.topic
      end

      def push!(notification)
        # Don't load lowdown earlier as it may load Celluloid (and start it)
        # before daemonizing the workers spun up by a gem (e,g, delayed_job).
        require 'lowdown' unless defined?(Lodwown)

        lowdown_notification = Lowdown::Notification.new(token: notification.device_token)
        lowdown_notification.payload = notification.payload
        lowdown_notification.topic   = @topic

        response = nil
        client.group do |group|
          group.send_notification(lowdown_notification) do |_response|
            response = _response
          end
        end

        raise response.raw_body if !response.success?
        ApnResponse.new(response)
      rescue => cause
        error = Pushing::ApnDeliveryError.new("Error while trying to send push notification: #{cause.message}", ApnResponse.new(response))

        raise error, error.message, cause.backtrace
      end

      private

      def client
        self.class.client(@certificate_path, @environment)
      end

      def self.client(cert_path, env)
        @@clients[env] || @@semaphore.synchronize do
          @@clients[env] ||= Lowdown::Client.production(env.production?, certificate: File.read(cert_path), keep_alive: true)
        end
      end

      class ApnResponse < SimpleDelegator
        def code
          __getobj__.status
        end

        def json
          JSON.parse(__getobj__.raw_body, symbolize_names: true) if __getobj__.raw_body
        end
      end

      private_constant :ApnResponse
    end
  end
end
