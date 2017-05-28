# frozen-string-literal: true

require 'pushing/log_subscriber'
require 'pushing/rescuable'
require 'pushing/template_handlers'

module Pushing
  class Base < AbstractController::Base
    include Rescuable

    abstract!

    include AbstractController::Rendering
    include AbstractController::Logger
    include AbstractController::Helpers
    include AbstractController::Translation
    include AbstractController::AssetPaths
    include AbstractController::Callbacks
    begin
      include AbstractController::Caching
    rescue NameError
      # AbstractController::Caching does not exist in rails 4.2. No-op.
    end

    include ActionView::Layouts

    PROTECTED_IVARS = AbstractController::Rendering::DEFAULT_PROTECTED_INSTANCE_VARIABLES + [:@_action_has_layout]

    def _protected_ivars # :nodoc:
      PROTECTED_IVARS
    end

    helper Pushing::NotificationHelper

    cattr_accessor :deliver_later_queue_name
    self.deliver_later_queue_name = :notifiers

    cattr_reader :delivery_notification_observers
    @@delivery_notification_observers = []

    cattr_reader :delivery_interceptors
    @@delivery_interceptors = []

    class << self
      delegate :deliveries, :deliveries=, to: Pushing::Adapters::TestAdapter

      # Register one or more Observers which will be notified when notification is delivered.
      def register_observers(*observers)
        observers.flatten.compact.each { |observer| register_observer(observer) }
      end

      # Register one or more Interceptors which will be called before notification is sent.
      def register_interceptors(*interceptors)
        interceptors.flatten.compact.each { |interceptor| register_interceptor(interceptor) }
      end

      # Register an Observer which will be notified when notification is delivered.
      # Either a class, string or symbol can be passed in as the Observer.
      # If a string or symbol is passed in it will be camelized and constantized.
      def register_observer(observer)
        unless delivery_notification_observers.include?(observer)
          delivery_notification_observers << observer
        end
      end

      # Register an Interceptor which will be called before notification is sent.
      # Either a class, string or symbol can be passed in as the Interceptor.
      # If a string or symbol is passed in it will be camelized and constantized.
      def register_interceptor(interceptor)
        unless delivery_interceptors.include?(interceptor)
          delivery_interceptors << interceptor
        end
      end

      def inform_observers(notification, response)
        delivery_notification_observers.each do |observer|
          observer.delivered_notification(notification, response)
        end
      end

      def inform_interceptors(notification)
        delivery_interceptors.each do |interceptor|
          interceptor.delivering_notification(notification)
        end
      end

      def notifier_name
        @notifier_name ||= anonymous? ? "anonymous" : name.underscore
      end
      # Allows to set the name of current notifier.
      attr_writer :notifier_name
      alias :controller_path :notifier_name

      # Wraps a notification delivery inside of <tt>ActiveSupport::Notifications</tt> instrumentation.
      def deliver_notification(notification) #:nodoc:
        ActiveSupport::Notifications.instrument("deliver.push_notification") do |payload|
          set_payload_for_notification(payload, notification)
          yield # Let NotificationDelivery do the delivery actions
        end
      end

      private

      def set_payload_for_notification(payload, notification)
        payload[:notifier]     = name
        payload[:notification] = notification.message.to_h
      end

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

    def process(method_name, *args) #:nodoc:
      payload = {
        notifier: self.class.name,
        action: method_name,
        args: args
      }

      ActiveSupport::Notifications.instrument("process.push_notification", payload) do
        super
        @_notification ||= NullNotification.new
      end
    end

    class NullNotification #:nodoc:
      def respond_to?(string, include_all = false)
        true
      end

      def method_missing(*args)
        nil
      end
    end

    attr_internal :notification

    def push(headers = {}, &block)
      return notification if notification && headers.blank? && !block

      payload = headers.select {|_, options| options }.reduce({}) do |acc, (platform, options)|
        lookup_context.variants = platform
        json = collect_responses(headers, &block)

        acc.update(platform => build_payload(platform, json, options))
      end

      # TODO: Do not use OpenStruct
      @_notification = OpenStruct.new(payload)
    end

    private

    def collect_responses(headers)
      #if block_given?
      #  collector = Pushing::Collector.new(lookup_context) { render(action_name) }
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
      engine   = File.extname(template.identifier).tr!(".", "")
      handler  = ::Pushing::TemplateHandlers.lookup(engine)

      template.instance_variable_set(:@handler, handler)

      render(template: template)
    end

    def build_payload(platform, json, options)
      ::Pushing::Platforms.lookup(platform).new(json, options)
    end

    ActiveSupport.run_load_hooks(:pushing, self)
  end
end
