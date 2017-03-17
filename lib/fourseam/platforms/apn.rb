module Fourseam
  module PlatformSupport
    class Apn
      attr_accessor :adapter, :certificate_path, :environment

      def initialize(*)
        @environment = 'development' # TODO: Use Rails.env to figure out the RAILS_ENV
      end

      def certificate
        @certificate ||= File.read(certificate_path)
      end
    end
  end
end
