require 'fourseam/platforms/apn'
require 'fourseam/platforms/fcm'

module Fourseam
  module PlatformSupport
    extend ActiveSupport::Concern

    included do
      cattr_reader :platforms
      @@platforms = [:apn, :fcm]

      cattr_reader :apn
      @@apn = PlatformSupport::Apn.new
      apn.adapter = :houston # TODO: Move this to Railties

      cattr_reader :fcm
      @@fcm = PlatformSupport::Fcm.new
      fcm.adapter = :squeeze # TODO: Move this to Railties
    end
  end
end
