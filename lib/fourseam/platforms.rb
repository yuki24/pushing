# frozen-string-literal: true

require 'fourseam/platforms/apn'
require 'fourseam/platforms/fcm'

module Fourseam
  module Platforms
    extend ActiveSupport::Concern

    included do
      config.apn = ActiveSupport::OrderedOptions.new
      config.fcm = ActiveSupport::OrderedOptions.new
    end

    PAYLOAD = "Payload".freeze
    private_constant :PAYLOAD

    class << self
      def lookup(platform_name)
        const_get("#{platform_name.to_s.camelize}#{PAYLOAD}")
      end
    end

    def build_payload(platform, json, options)
      ::Fourseam::Platforms.lookup(platform).new(json, options)
    end
  end
end
