# frozen-string-literal: true

require 'jbuilder/jbuilder_template'

module Pushing
  module TemplateHandlers
    class JbuilderHandler < ::JbuilderHandler
      def self.call(*)
        super.gsub("json.target!", "json.attributes!")
      end
    end
  end
end
