# frozen-string-literal: true

module Pushing
  module TemplateHandlers
    class JbuilderHandler
      def self.call(template)
        # this juggling is required to keep line numbers right in the error
        %{__already_defined = defined?(json); json||=JbuilderTemplate.new(self); #{template.source}
        json.attributes! unless (__already_defined && __already_defined != "method")}
      end
    end
  end
end
