module Zombie
	module HttpHelper

		%w(get post put patch delete head).each do |method|
			send :define_method, method do |url, payload={}, headers={}, &block|
				# begin
					url = "#{Zombie.service_host}/api/#{Zombie.version}/#{url}.json"
					RestClient::Request.execute(
						method: method, url: url, payload: payload, headers: headers, &block
					)
				# rescue Exception => e
					# puts e.message
					# puts e.http_body if e.respond_to?(:http_body)
					# puts e.backtrace[0..10]
				# end
			end
		end

	end
end
