# frozen-string-literal: true

require "active_support/dependencies/autoload"

module Pushing
  module TemplateHandlers
    extend ActiveSupport::Autoload

    autoload :JbuilderHandler

    def self.lookup(template)
      const_get("#{template.to_s.camelize}Handler")
    rescue NameError
      raise NotImplementedError.new("The template engine `#{template}' is not yet supported.")
    end
  end
end
