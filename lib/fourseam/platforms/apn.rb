module Fourseam
  module PlatformSupport
    module Apn
      class Payload
        attr_reader :device_token

        def initialize(payload, device_token)
          @payload, @device_token = payload, device_token
        end

        def recipients
          Array(@device_token) # TODO: make sure device tokens can be an array
        end

        # TODO: You shouldn't have to parse the json
        def payload
          JSON.parse(@payload, symbolize_names: true)
        end
      end
    end
  end
end
