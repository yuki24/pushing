require 'fourseam/platforms/apn'
require 'fourseam/platforms/fcm'

module Fourseam
  module PlatformSupport
    extend ActiveSupport::Concern

    included do
      cattr_accessor :platforms
      self.platforms = [:apn, :fcm]

      cattr_accessor :apn
      self.apn = PlatformSupport::Apn.new
      self.apn.adapter = :houston # TODO: Move this to Railties

      cattr_accessor :fcm
      self.fcm = PlatformSupport::Fcm.new
      self.fcm.adapter = :robo_msg # TODO: Move this to Railties
    end
  end
end
