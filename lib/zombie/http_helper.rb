require 'zombie/exception'

module Zombie
	module HttpHelper

		# class_request :get, :users, 1, [  [ :where, [{id:1}] ], [ :exists?, [id:1] ]  ]
		def instance_requests(http_method, resources, id, methods, headers={}, &blk)
			methods = parse_and_check_methods! methods
			url = simple_url_for "#{resources}/#{id}", methods
			request http_method, url, methods, headers, &blk
		end

		# instance_request :get, :users, 1, :update, {name: 'new_name'}
		def instance_request(http_method, resources, id, method=nil, params={}, headers={}, &blk)
			if method.present?
				check_method_name!(method)
				method = "/#{method}"
			end

			url = base_url_for("#{resources}/#{id}#{method}")
			payload = { resources => params }

			request http_method, url, payload, headers, &blk
		end

		# class_request :get, :users, [  [ :where, [{id:1}] ], [ :exists?, [id:1] ]  ]
		# class_request :get, :users, :_model_structure_
		def class_request(http_method, resources, methods, headers={}, &blk)
			methods = parse_and_check_methods! methods
			url = simple_url_for resources, methods
			request http_method, url, methods, headers, &blk
		end

		%w(get put patch post head delete).each do |meth|
			define_method "instance_#{meth}" do |resources, id, method=nil, params={}, headers={}, &blk|
				instance_request meth, resources, id, method, params, headers, &blk
			end

			define_method "instance_#{meth}s" do |resources, id, methods, headers={}, &blk|
				instance_requests meth, resources, id, methods, headers, &blk
			end

			define_method "class_#{meth}" do |resources, methods, headers={}, &blk|
				class_request meth, resources, methods, headers, &blk
			end
		end

		def request(http_method, url, payload={}, headers={}, &blk)
			begin

				res = RestClient::Request.execute(
					method: http_method, url: url, payload: payload, headers: headers, &blk
				)
				block_given? or parse_json(res)['results']

			rescue RestClient::Exception => e
				res = parse_json(e.http_body)

				backtrace = res['backtrace'] + e.zombie_backtrace
				puts backtrace
				puts ''
				error_class = get_or_set_exception(res['error'])
				error = error_class.new(res['message'])
				error.set_backtrace(backtrace)
				raise error
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
			url = resources.split('/').map { |str| CGI::escape str }.join('/')
			"#{Zombie.service_host}/api/#{Zombie.version}/zombie/#{url}.json"
		end

		def get_or_set_exception(const)
			Zombie.const_defined?(const) and return Zombie.const_get(const)
			Zombie.const_set(const, Class.new(Error))
		end


		private

		def parse_and_check_methods!(methods)
			methods == {} and raise InvalidMethodName.new("methods hash should not be blank")
			methods.blank? and invalid_method_name!(methods)

			case methods
			when String, Symbol
				{ args: [].to_json, method: methods }
			when Array
				methods.each do |meth|
					check_method_name!(meth.first)
					check_method_arguments!(meth.last)
				end
				if methods.length == 1
					{ args: methods.first.last.to_json, method: methods.first.first }
				else
					{ methods: methods.to_json }
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
