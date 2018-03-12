require "isolated_test_helper"

class RailtieTest < ActiveSupport::TestCase
  include Generation

  setup do
    build_app
    FileUtils.rm_rf "#{app_path}/config/environments"
  end

  test "sets pushing load paths" do
    add_to_config <<-RUBY
        config.root = "#{app_path}"
    RUBY

    require "#{app_path}/config/environment"

    expanded_path = File.expand_path("app/views", app_path)
    assert_equal expanded_path, Pushing::Base.view_paths[0].to_s
  end
end

