module Zombie
	class Error < Exception ; end

	class InvalidResponse < Error
	end

	class InvalidMethodName < Error
	end

	class InvalidArguments < Error
	end
end
