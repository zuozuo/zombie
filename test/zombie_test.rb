require 'test_helper'

class ZombieTest < ActiveSupport::TestCase
	setup do
		Zombie.options= nil
	end

  test "const DEFAULTS" do
		assert_equal Zombie::DEFAULTS, {
			redis_port: '6379',
			redis_host: '127.0.0.1',
			service_root_path: '/api',
			service_name: 'order_server',
			service_host: 'http://127.0.0.1:3000',
			api_server_host: 'http://127.0.0.1:80',
			router_conf_path: 'http://127.0.0.1:12121/set_model_path'
		}
  end

	test "self.configure" do
		assert_respond_to(Zombie, :configure)
		assert_equal Zombie.configure { 'test' }, 'test'
	end

	test "self.options" do
		assert_respond_to(Zombie, :options)
		assert_equal Zombie.options, Zombie::DEFAULTS
	end

	test "self.options=" do
		assert_respond_to(Zombie, :options=)
		Zombie.options= {}
		assert_equal Zombie.options, {}
	end

end
