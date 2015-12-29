class ActiveRecord::Base
	def self._model_structure_
		{}.tap do |hash|
			hash[:columns] = {}
			self.columns_hash.each { |k, v| hash[:columns][k] = v.type }

			exceptions = Object.public_methods

			hash[:class_methods] = self.public_methods - exceptions
			hash[:instance_methods] = self.public_instance_methods - exceptions
		end
	end
end
