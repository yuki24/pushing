# frozen-string-literal: true

module Pushing
  module Platforms
    class FcmPayload
      attr_reader :payload

      def initialize(payload, *)
        @payload = payload
      end

      def recipients
        Array(payload['to']) # TODO: make sure the :to key can hold an array
      end
    end
  end
end
