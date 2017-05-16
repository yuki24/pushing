module Fourseam
  class Railtie < Rails::Railtie # :nodoc:
    # config.eager_load_namespaces << Fourseam

    initializer "fourseam.logger" do
      ActiveSupport.on_load(:fourseam) { self.logger ||= Rails.logger }
    end

    initializer "fourseam.add_view_paths" do |app|
      views = app.config.paths["app/views"].existent
      if !views.empty?
        ActiveSupport.on_load(:fourseam) { prepend_view_path(views) }
      end
    end
  end
end
