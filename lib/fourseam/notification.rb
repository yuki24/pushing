module Fourseam
  class Notification
    attr_accessor :apn, :fcm

    def initialize(apn: nil, fcm: nil)
      @apn, @fcm = apn, fcm
    end
  end
end
