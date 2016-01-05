class ActiveRecord::Base
	def self._model_structure_
		{}.tap do |hash|
			hash[:columns] = {}
			self.columns_hash.each { |k, v| hash[:columns][k] = v.type }

			exceptions = Object.public_methods + [:method_missing, :define_singleton_method, :method, :public_method, :singleton_method]

			hash[:class_methods] = self.public_methods - exceptions
			hash[:instance_methods] = self.public_instance_methods - exceptions
		end
	end
end

class Exception
	def zombie_backtrace
		arr = []
		self.backtrace.each do |line|
			arr << line
			line =~ /zombie\/lib\/zombie/ and return arr
		end
	end
end

class String
	def  valid_method_name?
		self.to_sym.valid_method_name?
	end
end

class Symbol
	def valid_method_name?
		return /[@$"]/ !~ inspect
	end
end
