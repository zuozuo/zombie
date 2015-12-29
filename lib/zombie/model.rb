module Zombie
	class Model

		attr_reader :attributes

		delegate :[], to: :attributes

		def initialize(attributes={})
			@attributes = attributes.with_indifferent_access

			@attributes.each do |k, v|
				self.define_singleton_method k do; v; end
			end
		end

		def self.model_name
			self.to_s.demodulize.underscore
		end

		def self.resource_name
			self.model_name.pluralize
		end

		def self.zombie_path
			"#{self.resource_name}/zombie"
		end

		def self.collection
			@collection ||= Collection.new(self)
		end

		def self.model_structure=(structure={})
			undef_method *self.model_class_methods
			
			s = structure.with_indifferent_access
			s[:class_methods] = s[:class_methods] - self.public_methods
			s[:instance_methods] = s[:instance_methods] - self.public_instance_methods
			@model_structure = s

			self.extend SingleForwardable
			self.def_delegators :collection, *self.model_class_methods
		end

		def self.model_structure
			@model_structure ||= ActiveSupport::HashWithIndifferentAccess.new
		end

		def self.columns
			self.model_structure[:columns] || {}
		end

		def self.model_methods
			self.model_structure[:instance_methods] || []
		end

		def self.model_class_methods
			self.model_structure[:class_methods] || []
		end

	end
end
