module Fourseam
  module PlatformSupport
    module Fcm
      class Settings
        attr_accessor :adapter, :server_key

        def initialize
          @adapter, @server_key = :robo_msg, nil
        end

        # TODO: Why would you even need this!?
        def platform
          :fcm
        end
      end

      class Payload
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
