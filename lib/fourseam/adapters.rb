module Fourseam
  module Adapters
    extend ActiveSupport::Autoload

    autoload :HoustonAdapter, 'fourseam/adapters/apn/houston_adapter'
    autoload :ApnoticAdapter, 'fourseam/adapters/apn/apnotic_adapter'
    autoload :RoboMsgAdapter, 'fourseam/adapters/fcm/robo_msg_adapter'
    autoload :TestAdapter

    ADAPTER = "Adapter".freeze
    private_constant :ADAPTER

    class << self
      def lookup(name)
        const_get(name.to_s.camelize << ADAPTER)
      end
    end
  end
end
