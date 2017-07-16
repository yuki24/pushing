# frozen-string-literal: true

require 'jbuilder/jbuilder_template'

module Pushing
  module TemplateHandlers
    class JbuilderHandler < ::JbuilderHandler
      def self.call(*)
        super.gsub("json.target!", "json.attributes!").gsub("new(self)", "new(self, key_formatter: ::Pushing::TemplateHandlers::JbuilderHandler)")
      end

      def self.format(key)
        key
      end
    end
  end
end
