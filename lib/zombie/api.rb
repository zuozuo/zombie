module Zombie
  class API < Grape::API

		version Zombie.version, using: :path
		format :json
		prefix :api

		helpers do
			def arguments
				params[:args].blank? ? [] : JSON.parse(params[:args])
			end

			def resource_model
				params[:resources].singularize.camelcase.constantize
			end
			
			def request_method
				request.env['REQUEST_METHOD'].to_sym
			end

			def handle_instance_crud
				resource_model.find(params[:id_or_method]).tap do |resource|
					case request_method
					when :PUT, :POST, :PATCH
						resource.update!(params[params[:resources]])
					when :GET, :HEAD
						# do nothing, just return the finded resource
					when :DELETE
						resource.destroy!
					end
				end
			end
		end

		namespace :zombie do

			params do
        requires :methods, type: String, desc: 'Zombie methods'
			end
			route :any, ":resources" do

				objects = resource_model
				methods = JSON.parse(params[:methods])
				case methods
				when Array
					methods.each { |m| objects = objects.send(m.first, *m.last) }
				when Hash
					methods.each { |m, args| objects = objects.send(m, *args) }
				else
					#TODO raise params[:methods] invalid error
				end

				{ results: objects }
			end 

			params do
        requires :id_or_method, type: String, desc: 'id params or method name', regexp: /(\A[0-9]*\Z)|(\A([a-zA-Z_]+|\[\])[\?!=]?\Z)/
			end
			route :any, ":resources/:id_or_method" do
				{}.tap do |hash|
					hash[:results] = if params[:id_or_method].to_i.zero?
														 resource_model.send(params[:id_or_method], *arguments)
													 else
														 handle_instance_crud
													 end
				end
			end

			params do
				requires :id, type: Integer, desc: 'resource id'
				requires :method, type: String, desc: 'resource instance method', regexp: /\A([a-zA-Z_]+|\[\])[\?!=]?\Z/
			end
			route :any, ":resources/:id/:method" do
				{ results: resource_model.find(params[:id]).send(params[:method]) }
			end 
		end
	end
end
