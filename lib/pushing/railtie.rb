module Pushing
  class Railtie < Rails::Railtie # :nodoc:
    # config.eager_load_namespaces << Pushing

    initializer "pushing.logger" do
      ActiveSupport.on_load(:pushing) { self.logger ||= Rails.logger }
    end

    initializer "pushing.add_view_paths" do |app|
      views = app.config.paths["app/views"].existent
      if !views.empty?
        ActiveSupport.on_load(:pushing) { prepend_view_path(views) }
      end
    end

    initializer "pushing.compile_config_methods" do
      ActiveSupport.on_load(:pushing) do
        config.compile_methods! if config.respond_to?(:compile_methods!)
      end
    end
  end
end
