# frozen-string-literal: true

require 'active_support/configurable'

require 'pushing/platforms/apn'
require 'pushing/platforms/fcm'

module Pushing
  module Platforms
    include ActiveSupport::Configurable
    extend ActiveSupport::Concern

    config.apn = ActiveSupport::OrderedOptions.new
    config.fcm = ActiveSupport::OrderedOptions.new

    class << self
      def lookup(platform_name)
        const_get("#{platform_name.to_s.camelize}Payload")
      end
    end
  end
end
