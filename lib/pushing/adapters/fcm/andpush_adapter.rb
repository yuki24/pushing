require 'andpush'

module Pushing
  module Adapters
    class AndpushAdapter
      def initialize(fcm_settings)
        @server_key = fcm_settings.server_key
      end

      def push!(notification)
        self.class.client(@server_key).push(notification.payload)
      rescue => e
        raise Pushing::FcmDeliveryError.new("Error while trying to send push notification: #{e.message}", e.response)
      end

      @@semaphore = Mutex.new

      def self.client(server_key)
        @client || @@semaphore.synchronize { @client = Andpush.build(server_key) }
      end
    end
  end
end
