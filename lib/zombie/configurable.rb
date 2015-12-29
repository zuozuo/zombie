module Zombie
	module Configurable
		def self.extended(base)

			base.const_set :DEFAULTS, { 
				version: 'v1',
				redis_port: '6379',
				redis_host: '127.0.0.1',
				service_root_path: '/api',
				service_name: 'order_server',
				service_host: 'http://127.0.0.1:3000',
				api_server_host: 'http://127.0.0.1:80',
				router_conf_path: 'http://127.0.0.1:12121/set_model_path'
			}

			base.class_eval do
				DEFAULTS.each do |k, v|
					self.define_singleton_method "#{k}=" do |value|
						self.options.merge!(k => value)
					end

					self.define_singleton_method k do
						self.options[k]
					end
				end
			end
		end

		def configure
			yield self
		end

		def options
			@options ||= DEFAULTS.dup
		end

		def options=(opts)
			@options = opts
		end

	end
end
