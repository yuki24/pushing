module Fourseam
  class Base < AbstractController::Base
    abstract!

    include AbstractController::Rendering
    include AbstractController::Logger
    include AbstractController::Helpers
    include AbstractController::Translation
    include AbstractController::AssetPaths
    include AbstractController::Callbacks
    include AbstractController::Caching

    include ActionView::Layouts

    PROTECTED_IVARS = AbstractController::Rendering::DEFAULT_PROTECTED_INSTANCE_VARIABLES + [:@_action_has_layout]

    def _protected_ivars # :nodoc:
      PROTECTED_IVARS
    end

    helper Fourseam::NotificationHelper

    class << self
      def notifier_name
        @notifier_name ||= anonymous? ? "anonymous" : name.underscore
      end
      # Allows to set the name of current notifier.
      attr_writer :notifier_name
      alias :controller_path :notifier_name

      def method_missing(method_name, *args)
        if action_methods.include?(method_name.to_s)
          NotificationDelivery.new(self, method_name, *args)
        else
          super
        end
      end

      def respond_to_missing?(method, include_all = false)
        action_methods.include?(method.to_s) || super
      end
    end

    attr_internal :notification

    def initialize
      super()
      @_push_was_called = false
      @_notification = Notification.new
    end

    def push(headers = {}, &block)
      return notification if @_push_was_called && headers.blank? && !block

      headers.each do |platform, options|
        lookup_context.variants = platform
        json = collect_responses(headers, &block)
        notification.public_send(:"#{platform}=", self.class.const_get(platform.to_s.classify).new(json, options))
      end
      @_push_was_called = true

      notification
    end

    private

    def collect_responses(headers)
      #if block_given?
      #  collector = Fourseam::Collector.new(lookup_context) { render(action_name) }
      #  yield(collector)
      #  collector.responses
      #elsif headers[:body]
      #  collect_responses_from_text(headers)
      #else
      collect_responses_from_templates(headers)
      #end
    end

    def collect_responses_from_templates(headers)
      templates_path = headers[:template_path] || self.class.notifier_name
      templates_name = headers[:template_name] || action_name

      template = lookup_context.find(templates_name, Array(templates_path))
      render(template: template)
    end

    class Apn
      attr_reader :device_token, :payload

      def initialize(payload, device_token)
        @payload, @device_token = payload, device_token
      end
    end

    class Fcm
      attr_reader :payload

      def initialize(payload, *)
        @payload = payload
      end
    end
  end

  class Notification
    attr_accessor :apn, :fcm
  end
end
