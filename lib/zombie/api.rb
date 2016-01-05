module Zombie
  class API < Grape::API

		version Zombie.version, using: :path
		format :json
		prefix :api

		rescue_from :all do |e|
			Rails.logger.error e.class.name
			Rails.logger.error e.message
			e.zombie_backtrace.each {|line| Rails.logger.error line }

			error!({
				error: e.class.name,
				message: e.message,
				backtrace: e.zombie_backtrace
			}, 500)
		end

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

			def execute_chain_methods_for(resources)
				methods = JSON.parse(params[:methods])
				case methods
				when Array
					methods.each { |m| resources = resources.send(m.first, *m.last) }
				else
					raise "invalid params[:methods]: #{params[:methods]}, params[:methods].should be an array to_json"
				end
				resources
			end

			def handle_instance_methods
				resource = resource_model.find(params[:id_or_method])
				if params[:methods].present?
					execute_chain_methods_for(resource)
				else
					handle_instance_crud(resource)
				end
			end

			def handle_instance_crud(resource)
				case request_method
				when :PUT, :POST, :PATCH
					resource.update!(params[params[:resources]])
				when :GET, :HEAD
					# do nothing, just return the finded resource
				when :DELETE
					resource.destroy!
				end
				resource
			end
		end

		namespace :zombie do

			before do
				puts params
				@return = {}
			end

			after do
				objects = @return[:results]
				model = (
					objects.respond_to?(:first) and
					objects.first.is_a?(ActiveRecord::Base) and
					objects.first.class.name
				)
				@return[:model] = model || objects.class.name
			end

			params do
        requires :methods, type: String, desc: 'Zombie methods'
			end
			route :any, ":resources" do
				@return.merge!(results: execute_chain_methods_for(resource_model))
			end 

			params do
        requires :id_or_method, type: String, desc: 'id params or method name', regexp: /(\A[0-9]*\Z)|(\A([a-zA-Z_]+|\[\])[\?!=]?\Z)/
			end
			route :any, ":resources/:id_or_method" do
				objects = if params[:id_or_method].to_i.zero?
										resource_model.send(params[:id_or_method], *arguments)
									else
										handle_instance_methods
									end
				@return.merge!(results: objects)
			end

			params do
				requires :id, type: Integer, desc: 'resource id'
				requires :method, type: String, desc: 'resource instance method', regexp: /\A([a-zA-Z_]+|\[\])[\?!=]?\Z/
			end
			route :any, ":resources/:id/:method" do
				@return.merge!(results: resource_model.find(params[:id]).send(params[:method], *arguments))
			end 
		end
	end
end
