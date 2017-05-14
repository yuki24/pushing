module Fourseam
  class Railtie < Rails::Railtie # :nodoc:
    initializer "fourseam.add_view_paths" do |app|
      views = app.config.paths["app/views"].existent
      if !views.empty?
        ActiveSupport.on_load(:fourseam) { prepend_view_path(views) }
      end
    end
  end
end
