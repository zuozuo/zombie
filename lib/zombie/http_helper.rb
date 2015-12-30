require 'zombie/exception'

module Zombie
	module HttpHelper

		def instance_request(http_method, resources, id, method=nil, params={}, headers={}, &blk)
			if method.present?
				check_method_name!(method)
				method = "/#{method}"
			end

			url = base_url_for("#{resources}/#{id}#{method}")
			payload = { resources => params }

			request http_method, url, payload, headers, &blk
		end

		def class_request(http_method, resources, methods, headers={}, &blk)
			methods = parse_and_check_methods! methods
			url = simple_url_for resources, methods
			request http_method, url, methods, headers, &blk
		end

		def request(http_method, url, payload={}, headers={}, &blk)
			begin

				res = RestClient::Request.execute(
					method: http_method, url: url, payload: payload, headers: headers, &blk
				)
				parse_json(res)['results']

			rescue Exception => e
				# TODO handle request exception for zombie
				raise e
				# puts e.message
				# puts e.http_body if e.respond_to?(:http_body)
				# puts e.backtrace[0..10]
			end
		end

		def parse_json(json)
		  begin
				JSON.parse(json)
		  rescue JSON::ParserError => e
				json
		  end
		end

		def url_for(resources, methods={})
			simple_url_for resources, parse_and_check_methods!(methods)
		end

		def base_url_for(resources)
			"#{Zombie.service_host}/api/#{Zombie.version}/zombie/#{resources}.json"
		end

		private

		def parse_and_check_methods!(methods)
			methods == {} and raise InvalidMethodName.new("methods hash should not be blank")
			methods.blank? and invalid_method_name!(methods)

			case methods
			when String, Symbol
				{ args: [].to_json, method: methods }
			when Hash
				methods.each do |meth, args|
					check_method_name!(meth)
					check_method_arguments!(args)
				end
				if methods.length == 1
					{ args: methods.values.first.to_json, method: methods.keys.first }
				else
					{ methods: methods.to_a.to_json }
				end
			else
				invalid_method_name! methods
			end
		end

		def check_method_arguments!(args)
			args.is_a?(Array) or raise InvalidArguments.new("arguments should be passed in an Array")
		end

		def check_method_name!(method_name)
			method_name.valid_method_name? or invalid_method_name!(method_name)
		end

		def invalid_method_name!(method_name)
			method_name = case method_name
										when nil
											'nil'
										when String
											"'#{method_name}'"
										else
											method_name
										end
			raise InvalidMethodName.new("#{method_name} is not a valid ruby method name")
		end

		def simple_url_for(resources, methods={})
			if methods.key?(:methods)
				base_url_for("#{resources}")
			elsif methods.key?(:args)
				base_url_for("#{resources}/#{methods[:method]}")
			elsif methods.key?(:id)
				base_url_for("#{resources}/#{methods[:id]}")
			end
		end
		
	end
end
