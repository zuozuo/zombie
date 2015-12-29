require 'test_helper'

class UserApiTest < ActionController::TestCase
  include Rack::Test::Methods

	def app
		Test::V1::UserApi
	end

	def body
		JSON.parse(last_response.body)
	end

	setup do
	  app.include Zombie

		app.class_eval do
		  @model_name = nil
		  @model_attrs = nil
			@attr_blacklist = nil
		end
	end

	test "self.model" do
		assert_equal(app.model, User)

		app.source_model "TestModel"
		assert_raises(NameError) { app.model }
	end

	test "self.model_name" do
		assert_equal app.model_name, 'user'
	end

	test "self.resource_name" do
		assert_equal app.resource_name, 'users'
	end

	test "self.source_model" do
		app.source_model "User"

		assert_equal app.model_name, 'User'
		assert_equal app.model, User
	end

	test "self.attributes" do
		assert_equal(app.attributes, User.attribute_names.map(&:to_sym))
	end

	test "self.model_attrs" do
		app.model_attrs :name, :email

		assert_equal(app.attributes, [:name, :email])
	end

	test "self.attr_blacklist" do
		assert_equal app.attr_blacklist, []

		app.model_attr_blacklist :id
		assert_equal app.attr_blacklist, [:id]
	end

	test "self.model_attr_blacklist" do
		app.model_attr_blacklist :id

		assert_equal app.attributes, User.attribute_names.map(&:to_sym) - [:id]
	end

	test "self.model_attr_black_list" do
		app.model_attr_black_list :id

		assert_equal app.attributes, User.attribute_names.map(&:to_sym) - [:id]
	end

	test "/zombie*" do
		get '/api/v1/users/zombie.json', methods: { 
			order: 'id desc',
			where: { id: [1, 2] },
			select: [:name, :id] 
		}
		assert_response :success
		assert_equal body, [
			{ 'id' => 2, 'name' => 'User2' },
			{ 'id' => 1, 'name' => 'User1' }
		]
	end

end
