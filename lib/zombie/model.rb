module Zombie
	class Model
		extend HttpHelper
		include HttpHelper

		attr_reader :attributes

		delegate :[], to: :attributes

		def initialize(attributes={})
			@attributes = attributes.with_indifferent_access
		end

		%w(delete destroy delete! destroy!).each do |meth|
			define_method meth do |*args|
				require_id!(meth)
				@attributes = instance_delete resource_name, self.id, nil
				self
			end
		end

		%w(decrement decrement! increment increment!).each do |meth|
			define_method meth do |attribute, by=1|
				require_id!(meth)
				@attributes = instance_patchs resource_name, self.id, [ [meth, [attribute, by]] ]
				self
			end
		end
		
		%w(toggle toggle!).each do |meth|
			define_method meth do |attribute|
				require_id!(meth)
				res = instance_patchs resource_name, self.id, [ [meth, [attribute]] ]
				if res.is_a?(Hash)
					@attributes = res
					self
				else
					res
				end
			end
		end

		def touch(*names)
			require_id!(:touch)
			instance_patchs resource_name, self.id, [ [:touch, names] ]
		end

		%w(update_column update_attribute).each do |meth|
			define_method meth do |name, value|
				require_id!(meth)
				@attributes.merge!(name => value)
				instance_patchs resource_name, self.id, [ [meth, [name, value]] ]
			end
		end

		%w(update update! update_columns).each do |meth|
			define_method meth do |attrs={}|
				attrs.is_a?(Hash) or raise "arguments for #{meth} should be Hash"
				require_id!(meth)
				instance_patchs resource_name, self.id, [ [meth, [attrs]] ]
			end
		end
		alias update_attributes update
		alias update_attributes! update!

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

		# %w(first last find exists?).each do |meth|
		# 	self.define_singleton_method meth do |*args|
		# 		coll = self.collection
		# 		coll.conditions << [meth, args]
		# 		coll.load_data
		# 		coll.is_collection ? coll : coll.first
		# 	end
		# end

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

		def reload
			require_id!(:reload)
			@attributes = instance_get resource_name, self.id, nil
			self
		end
		alias reload! reload

		def inspect
			inspection = @attributes.map do |key, value|
				"#{key}: #{attribute_for_inspect(value)}"
			end.compact.join(", ")

			"#<#{self.class}:#{self.object_hexid}> #{inspection}"
		end

		def attribute_for_inspect(value)
			if value.is_a?(String) && value.length > 50
				"#{value[0, 50]}...".inspect
			elsif value.is_a?(Date) || value.is_a?(Time)
				%("#{value.to_s(:db)}")
			elsif value.is_a?(Array) && value.size > 10
				inspected = value.first(10).inspect
				%(#{inspected[0...-1]}, ...])
			else
				value.inspect
			end
		end

		def object_hexid
			"0x00" << (self.object_id << 1).to_s(16)
		end

		delegate :model_name, :resource_name, :collection_class, to: :class

		def require_id!(meth)
			self.id or raise "cannot #{meth} #{self} without an id"
		end

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

			def pluck(*names)
				class_get resource_name, [ [ :pluck, names ] ]
			end

			def ids
				pluck :id
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
