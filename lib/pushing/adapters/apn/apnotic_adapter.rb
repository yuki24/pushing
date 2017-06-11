# frozen-string-literal: true

require 'apnotic'
require 'active_support/core_ext/hash/except'

module Pushing
  module Adapters
    class ApnoticAdapter
      APS_DICTIONARY_KEYS = %w[
        alert
        badge
        sound
        content_available
        category
        url_args
        mutable_content
      ].freeze

      HEADER_KEYS = %i[
        apns_id
        expiration
        priority
        topic
        apns_collapse_id
      ].freeze

      def initialize(apn_settings)
        @certificate_path     = apn_settings.certificate_path
        @certificate_password = apn_settings.certificate_password
        @environment          = apn_settings.environment.to_sym
        @topic                = apn_settings.topic
      end

      def push!(notification)
        message = Apnotic::Notification.new(notification.device_token)
        json    = notification.payload

        if aps = json['aps']
          APS_DICTIONARY_KEYS.each {|key| message.instance_variable_set(:"@#{key}", aps[key]) }
        end

        message.custom_payload = json.except('aps')
        message.topic          = @topic

        response = connection_pool.with {|connection| connection.push(message) }

        if !response
          raise "Timeout sending a push notification"
        elsif response.status != '200'
          raise response.body.to_s
        end

        response
      rescue => e
        raise Pushing::ApnDeliveryError.new("Error while trying to send push notification: #{e.message}", response)
      end

      private

      # TODO: I don't like to configure connection pool at runtime. Is it possible to do so at
      #       booting time? Perhaps making adapters singleton and set them up in initializer?
      @@connection_pool = {}
      @@semaphore       = Mutex.new

      def connection_pool
        self.class.connection_pool(@certificate_path, @certificate_password, @environment)
      end

      def self.connection_pool(cert_path, cert_password, environment)
        @@semaphore.synchronize do
          @@connection_pool[environment] ||= begin
            ::ConnectionPool.new(size: 5) do
              Apnotic::Connection.new(
                cert_path: cert_path,
                cert_pass: cert_password,
                url: (::Apnotic::APPLE_DEVELOPMENT_SERVER_URL if environment != :production)
              )
            end
          end
        end
      end
    end
  end
end
