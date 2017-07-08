# frozen-string-literal: true

require 'json'
require 'fcm'
require 'active_support/core_ext/hash/slice'

module Pushing
  module Adapters
    class FcmGemAdapter
      SUCCESS_CODES = (200..299).freeze

      attr_reader :server_key

      def initialize(fcm_settings)
        @server_key = fcm_settings.server_key
      end

      def push!(notification)
        json     = notification.payload
        ids      = json.delete('registration_ids') || Array(json.delete('to'))
        response = FCM.new(server_key).send(ids, json)

        if SUCCESS_CODES.include?(response[:status_code])
          FcmResponse.new(response.slice(:body, :headers, :status_code).merge(raw_response: response))
        else
          raise "#{response[:response]} (response body: #{response[:body]})"
        end
      rescue => cause
        resopnse = FcmResponse.new(response.slice(:body, :headers, :status_code).merge(raw_response: response)) if response
        error    = Pushing::FcmDeliveryError.new("Error while trying to send push notification: #{cause.message}", resopnse, notification)

        raise error, error.message, cause.backtrace
      end

      class FcmResponse
        attr_reader :body, :headers, :status_code, :raw_response

        alias code status_code

        def initialize(body: , headers: , status_code: , raw_response: )
          @body, @headers, @status_code, @raw_response = body, headers, status_code, raw_response
        end

        def json
          @json ||= JSON.parse(body, symbolize_names: true) if body.is_a?(String)
        end
      end

      private_constant :FcmResponse
    end
  end
end
