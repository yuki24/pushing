# frozen-string-literal: true

require 'apnotic'

module Pushing
  module Adapters
    class ApnoticAdapter
      APS_DICTIONARY_KEYS = %i[
        alert
        badge
        sound
        content_available
        category
        url_args
        mutable_content
      ].freeze

      DEFAULT_ADAPTER_OPTIONS = {
        size: Process.getrlimit(Process::RLIMIT_NOFILE).first / 8
      }.freeze

      attr_reader :environment, :topic, :connection_pool

      def initialize(apn_settings)
        @environment = apn_settings.environment.to_sym
        @topic       = apn_settings.topic

        options = {
          cert_path: apn_settings.certificate_path,
          cert_pass: apn_settings.certificate_password
        }

        @connection_pool = {
          development: Apnotic::ConnectionPool.development(options, DEFAULT_ADAPTER_OPTIONS),
          production: Apnotic::ConnectionPool.new(options, DEFAULT_ADAPTER_OPTIONS),
        }
      end

      def push!(notification)
        message = Apnotic::Notification.new(notification.device_token)
        json    = notification.payload.dup

        if aps = json.delete(:aps)
          APS_DICTIONARY_KEYS.each {|key| message.instance_variable_set(:"@#{key}", aps[key]) }
        end

        message.custom_payload = json

        message.apns_id          = notification.headers[:'apns-id'] || message.apns_id
        message.expiration       = notification.headers[:'apns-expiration'].to_i
        message.priority         = notification.headers[:'apns-priority']
        message.topic            = notification.headers[:'apns-topic'] || topic
        message.apns_collapse_id = notification.headers[:'apns-collapse-id']

        response = connection_pool[notification.environment || environment].with {|connection| connection.push(message) }

        if !response
          raise "Timeout sending a push notification"
        elsif response.status != '200'
          raise response.body.to_s
        end

        ApnResponse.new(response)
      rescue => cause
        response = response ? ApnResponse.new(response) : nil
        error    = Pushing::ApnDeliveryError.new("Error while trying to send push notification: #{cause.message}", response, notification)

        raise error, error.message, cause.backtrace
      end

      class ApnResponse < SimpleDelegator
        def code
          __getobj__.status.to_i
        end
        alias status code

        def json
          @json ||= __getobj__.body.symbolize_keys if !__getobj__.body.empty?
        end
        alias body json
      end

      private_constant :ApnResponse
    end
  end
end
