module Pushing
  class NotifierGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("../templates", __FILE__)

    argument :actions, type: :array, default: [], banner: "method method"

    check_class_collision suffix: "Notifier"

    def create_notifier_file
      template "notifier.rb", File.join("app/notifiers", class_path, "#{file_name}_notifier.rb")

      actions.each do |action|
        template "template.json+apn.jbuilder", File.join("app/views/", "#{file_name}_notifier", "#{action}.json+apn.jbuilder")
        template "template.json+fcm.jbuilder", File.join("app/views/", "#{file_name}_notifier", "#{action}.json+fcm.jbuilder")
      end

      in_root do
        if behavior == :invoke && !File.exist?(application_notifier_file_name)
          template "application_notifier.rb", application_notifier_file_name
        end

        if behavior == :invoke && !File.exist?(initializer_file_name)
          template "initializer.rb", initializer_file_name
        end
      end
    end

    private

    def file_name # :doc:
      @_file_name ||= super.gsub(/_notifier/i, "")
    end

    def initializer_file_name
      @_initializer_file_name ||= "config/initializers/pushing.rb"
    end

    def application_notifier_file_name
      @_application_notifier_file_name ||= if mountable_engine?
                                           "app/notifiers/#{namespaced_path}/application_notifier.rb"
                                         else
                                           "app/notifiers/application_notifier.rb"
                                         end
    end
  end
end
