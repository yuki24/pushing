module Fourseam
  class Notification
    attr_accessor :apn, :fcm

    def initialize(apn: nil, fcm: nil)
      @apn, @fcm = apn, fcm
    end

    def self.build_payload(platform, json, options)
      const_get(platform.to_s.camelize).new(json, options)
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

      # TODO: You shouldn't have to parse the json
      def payload
        JSON.parse(@payload, symbolize_names: true)
      end
    end
  end
end
