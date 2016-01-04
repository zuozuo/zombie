module Zombie
	class Model
		extend HttpHelper
		include HttpHelper

		attr_reader :attributes

		delegate :[], to: :attributes

		def initialize(attributes={})
			@attributes = attributes.with_indifferent_access
		end

		%w(update update!).each do |meth|
			define_method meth do |attrs={}|
				attrs.is_a?(Hash) or raise "arguments for #{meth} should be Hash"
				self.id or raise "cannot update #{self.class} without an id"
				@attributes = instance_patch resource_name, self.id, nil, @attributes.merge(attrs)
				self
			end
		end
		alias update_attributes update
		alias update_attributes! update!

		def update_attribute(name, value)
			self.id or raise "cannot update #{self.class} without an id"
			@attributes = instance_patch resource_name, self.id, nil, @attributes.merge(name => value)
			self
		end

		%w(save save!).each do |meth|
			define_method meth do |*args|
				@attributes = if self.id
												instance_patch resource_name, self.id, nil, @attributes
											else
												class_post resource_name, [[:create, [@attributes]]]
											end
				self
			end
		end

		%w(first last find exists?).each do |meth|
			self.define_singleton_method meth do |*args|
				coll = self.collection
				coll.conditions << [meth, args]
				coll.load_data
				coll.is_collection ? coll : coll.first
			end
		end

		%w(create! create).each do |meth|
			self.define_singleton_method meth do |*args|
				self.new(class_post resource_name, [meth, args])
			end
		end

		def collection
			collection_class.new(self)
		end

		def <=> (other)
			self.id <=> other.id
		end

		delegate :model_name, :resource_name, :collection_class, to: :class

		class << self

			def model_name
				self.to_s.demodulize.underscore
			end

			def resource_name
				self.model_name.pluralize
			end

			def collection
				collection_class.new(self)
			end

			def collection_class
				model = "#{model_name.camelcase}Collection"
				Zombie.const_defined?(model) or Zombie.const_set model, Class.new(Collection)
				Zombie.const_get model
			end

			def reload
				self.model_structure = class_get resource_name, :_model_structure_
				self
			end
			alias reload! reload
			
			def model_structure=(structure={})
				s = structure.with_indifferent_access
				s[:class_methods] = s[:class_methods] - self.methods.map(&:to_s)
				s[:instance_methods] =
					s[:instance_methods] -
					self.instance_methods.map(&:to_s) -
					s[:columns].keys -
					s[:columns].keys.map {|key| "#{key}="}

				@model_structure = s

				collection_class.send :define_method, :method_missing do |meth, *args, &blk|
					if s[:class_methods].include?(meth.to_s) || s[:instance_methods].include?(meth.to_s)
						conditions << [meth, args]
						self.clone
					else
						super(meth, *args, &blk)
					end
				end

				s[:columns].each do |col, type|
					self.send :define_method, col do
						@attributes[col]
					end

					self.send :define_method, "#{col}=" do |value|
						@attributes[col] = value
					end
				end

				delegate *s[:instance_methods], to: :collection
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
