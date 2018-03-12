require "active_job/railtie"
require "rails"
require "abstract_controller/railties/routes_helpers"

module Pushing
  class Railtie < Rails::Railtie # :nodoc:
    config.eager_load_namespaces << Pushing

    initializer "pushing.logger" do
      ActiveSupport.on_load(:pushing) { self.logger ||= Rails.logger }
    end

    initializer "pushing.add_view_paths" do |app|
      views = app.config.paths["app/views"].existent
      if !views.empty?
        ActiveSupport.on_load(:pushing) { prepend_view_path(views) }
      end
    end

    initializer "pushing.set_configs" do |app|
      paths   = app.config.paths
      options = ActiveSupport::OrderedOptions.new
      options.default_url_options = {}

      if app.config.force_ssl
        options.default_url_options[:protocol] ||= "https"
      end

      options.assets_dir ||= paths["public"].first

      # make sure readers methods get compiled
      options.asset_host        ||= app.config.asset_host
      options.relative_url_root ||= app.config.relative_url_root

      ActiveSupport.on_load(:pushing) do
        include AbstractController::UrlFor
        extend ::AbstractController::Railties::RoutesHelpers.with(app.routes, false)
        include app.routes.mounted_helpers

        options.each { |k, v| send("#{k}=", v) }
        config.merge!(options)
      end
    end

    initializer "pushing.compile_config_methods" do
      ActiveSupport.on_load(:pushing) do
        config.compile_methods! if config.respond_to?(:compile_methods!)
      end
    end
  end
end
