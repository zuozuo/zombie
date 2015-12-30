module Zombie
  class API < Grape::API

		version Zombie.version, using: :path
		format :json
		prefix :api

		namespace :zombie do
			params do
        requires :methods, type: String, desc: 'Zombie methods'
			end

			route :any, ":resources" do
				binding.pry

				objects = options[:for].model
				JSON.parse(params[:methods]).each do |method, args|
					objects = objects.send(method, *args)
				end
				{ results: objects }
			end 

			params do
        requires :id_or_method, type: String, desc: 'id params or method name', regexp: /(\A[0-9]*\Z)|(\A([a-zA-Z_]+|\[\])[\?!=]?\Z)/
			end

			route :any, ":resources/:id_or_method" do

				objects = options[:for].model
				JSON.parse(params[:methods]).each do |method, args|
					objects = objects.send(method, *args)
				end
				{ results: objects }

			end 

			params do
				requires :id, type: Integer, desc: 'resource id'
				requires :method, type: String, desc: 'resource instance method', regexp: /\A([a-zA-Z_]+|\[\])[\?!=]?\Z/
			end

			route :any, ":resources/:id/:method" do
				objects = options[:for].model
				JSON.parse(params[:methods]).each do |method, args|
					objects = objects.send(method, *args)
				end
				{ results: objects }
			end 
		end
	end
end
