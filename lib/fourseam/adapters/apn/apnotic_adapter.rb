require 'apnotic'

module Fourseam
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
      ]

      HEADER_KEYS = %i[
        apns_id
        expiration
        priority
        topic
        apns_collapse_id
      ]

      def initialize(apn_settings)
        @certificate_path     = apn_settings.certificate_path
        @certificate_password = apn_settings.certificate_password
        @environment          = apn_settings.environment.to_sym
        @topic                = apn_settings.topic
      end

      def push!(notification)
        connection_pool.with do |connection|
          message = Apnotic::Notification.new(notification.device_token)
          json    = notification.payload

          if json.has_key?(:aps)
            aps = json[:aps]

            APS_DICTIONARY_KEYS.each do |key|
              message.instance_variable_set(:"@#{key}", aps[key])
            end
          end

          message.custom_payload = json.except(:aps)
          message.topic          = @topic

          response = connection.push(message)

          if !response
            raise "Timeout sending a push notification"
          elsif response.status != '200'
            raise response.body.to_s
          else
            response
          end
        end
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
