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
			s = structure.with_indifferent_access
			s[:model_class_methods] = s - self.public_methods
			s[:model_methods] = s - self.public_instance_methods
			@model_structure = s
			# self
		end

		def self.method_missing(meth, *args, &blk)
			if self.model_class_methods.include?(meth.to_s)
				collection.send(meth, *args, &blk)
			else
				super(meth, *args, &blk)
			end
		end

		def self.model_structure
			@model_structure ||= ActiveSupport::HashWithIndifferentAccess.new
		end

		def self.columns
			@model_structure[:columns]
		end

		def self.model_methods
			@model_structure[:instance_methods]
		end

		def self.model_class_methods
			@model_structure[:class_methods]
		end

	end
end
