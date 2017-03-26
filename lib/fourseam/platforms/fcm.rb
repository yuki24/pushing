module Fourseam
  module PlatformSupport
    # TODO: Rename it to FcmSettings
    class Fcm
      attr_accessor :adapter, :server_key

      def initialize
        @adapter, @server_key = :robo_msg, nil
      end

      class Payload
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
end
