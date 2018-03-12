require "isolated_test_helper"

class RailtieTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation
  include Generation

  setup do
    build_app
    FileUtils.rm_rf "#{app_path}/config/environments"
  end

  teardown do
    teardown_app
  end

  test "sets pushing load paths" do
    add_to_config <<-RUBY
        config.root = "#{app_path}"
    RUBY

    require "#{app_path}/config/environment"

    expanded_path = File.expand_path("app/views", app_path)
    assert_equal expanded_path, Pushing::Base.view_paths[0].to_s
  end

  test "sets default url options" do
    add_to_initializer <<-RUBY
      Pushing.configure do |config|
        config.default_url_options[:host] = 'www.example.org'
      end
    RUBY

    require "#{app_path}/config/environment"

    assert_equal 'www.example.org', Pushing::Base.default_url_options[:host]
  end

  test "sets asset host" do
    add_to_initializer <<-RUBY
      Pushing.configure do |config|
        config.asset_host = 'https://www.example.org'
      end
    RUBY

    require "#{app_path}/config/environment"

    assert_equal 'https://www.example.org', Pushing::Base.asset_host
  end
end
