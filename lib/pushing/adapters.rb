# frozen-string-literal: true

module Pushing
  module Adapters
    extend ActiveSupport::Autoload

    autoload :HoustonAdapter, 'pushing/adapters/apn/houston_adapter'
    autoload :ApnoticAdapter, 'pushing/adapters/apn/apnotic_adapter'
    autoload :RoboMsgAdapter, 'pushing/adapters/fcm/robo_msg_adapter'
    autoload :TestAdapter

    class << self
      def lookup(name)
        const_get("#{name.to_s.camelize}Adapter")
      end
    end
  end
end
