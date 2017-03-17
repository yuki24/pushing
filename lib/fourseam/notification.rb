module Fourseam
  class Notification
    attr_accessor :apn, :fcm, :delivery_handler, :delivery_method

    def deliver!
      # inform_interceptors
      response = delivery_method.deliver!(self)
      # inform_observers
      response
    end

    def set_payload(platform, payload, options)
      instance_variable_set(
        :"@#{platform}",
        self.class.const_get(platform.to_s.classify).new(payload, options)
      )
    end

    class Apn
      attr_reader :device_token

      def initialize(payload, device_token)
        @payload, @device_token = payload, device_token
      end

      # TODO: You shouldn't have to parse the json
      def payload
        JSON.parse(@payload, symbolize_names: true)
      end
    end

    class Fcm
      attr_reader :payload

      def initialize(payload, *)
        @payload = payload
      end
    end
  end
end
