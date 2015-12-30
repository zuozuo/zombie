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

		class << self
			def first
				c = self.collection
				c.conditions[:first] = []
				c.load_data
			end

			def last
				c = self.collection
				c.conditions[:last] = []
				c.load_data
			end

			def find(*ids)
				c = self.collection
				c.conditions[:find] = [ids]
				c.load_data
			end

			def model_name
				self.to_s.demodulize.underscore
			end

			def resource_name
				self.model_name.pluralize
			end

			def zombie_path
				"#{self.resource_name}/zombie"
			end

			def collection
				Collection.new(self)
			end

			def <=> (other)
				self.id <=> other.id
			end

			def model_structure=(structure={})

				s = structure.with_indifferent_access
				s[:class_methods] = s[:class_methods] - self.public_methods.map(&:to_s)
				s[:instance_methods] = s[:instance_methods] - self.public_instance_methods.map(&:to_s)

				@model_structure = s

				s[:class_methods].each do |meth|
					Collection.send :define_method, meth do |*args|
						conditions[meth] = args
						self.clone
					end
				end

				self.extend SingleForwardable
				self.def_delegators :collection, *s[:class_methods]
			end

			def model_structure
				@model_structure ||= ActiveSupport::HashWithIndifferentAccess.new
			end

			def columns
				self.model_structure[:columns] || {}
			end

			def model_methods
				self.model_structure[:instance_methods] || []
			end

			def model_class_methods
				self.model_structure[:class_methods] || []
			end

		end

	end
end
