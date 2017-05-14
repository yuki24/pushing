# frozen-string-literal: true

module Fourseam
  module Adapters
    extend ActiveSupport::Autoload

    autoload :HoustonAdapter, 'fourseam/adapters/apn/houston_adapter'
    autoload :ApnoticAdapter, 'fourseam/adapters/apn/apnotic_adapter'
    autoload :RoboMsgAdapter, 'fourseam/adapters/fcm/robo_msg_adapter'
    autoload :TestAdapter

    class << self
      def lookup(name)
        const_get("#{name.to_s.camelize}Adapter")
      end
    end
  end
end
