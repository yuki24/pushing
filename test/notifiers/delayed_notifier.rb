require "active_job/arguments"

class DelayedNotifierError < StandardError; end

class DelayedNotifier < Pushing::Base
  cattr_accessor :last_error
  cattr_accessor :last_rescue_from_instance

  if ActiveSupport::VERSION::MAJOR > 4
    rescue_from DelayedNotifierError do |error|
      @@last_error = error
      @@last_rescue_from_instance = self
    end

    rescue_from ActiveJob::DeserializationError do |error|
      @@last_error = error
      @@last_rescue_from_instance = self
    end
  end

  def test_message(*)
    push fcm: true
  end

  def test_raise(klass_name)
    raise klass_name.constantize, "boom"
  end
end
