require 'fourseam/platforms/apn'
require 'fourseam/platforms/fcm'

module Fourseam
  module PlatformSupport
    extend ActiveSupport::Concern

    included do
      cattr_accessor :platforms
      self.platforms = [:apn, :fcm]

      config.apn = ActiveSupport::OrderedOptions.new
      config.fcm = ActiveSupport::OrderedOptions.new
    end

    def build_payload(platform, json, options)
      PlatformSupport.const_get(platform.to_s.camelize)
        .const_get(:Payload)
        .new(json, options)
    end
  end
end
