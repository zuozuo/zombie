module Zombie
	class Collection
		include HttpHelper

		attr_reader :klass, :loaded, :collection, :is_collection

		Methods = :to_s, :==, :eql?, :[], :[]=, :at, :fetch, :first, :last, :concat, :<<, :push, :pop, :shift, :unshift, :insert, :length, :size, :empty?, :find_index, :index, :rindex, :join, :reverse, :reverse!, :rotate, :rotate!, :sort, :sort!, :sort_by!, :collect, :collect!, :select!, :keep_if, :values_at, :delete, :delete_at, :delete_if, :reject, :reject!, :zip, :transpose, :replace, :clear, :fill, :include?, :<=>, :slice, :slice!, :+, :*, :-, :&, :|, :uniq, :uniq!, :compact, :compact!, :flatten, :flatten!, :count, :shuffle!, :shuffle, :sample, :cycle, :permutation, :combination, :repeated_permutation, :repeated_combination, :product, :take, :take_while, :drop, :drop_while, :bsearch, :pack, :append, :prepend, :extract_options!, :blank?, :deep_dup, :to_param, :to_query, :to_sentence, :to_formatted_s, :to_default_s, :to_xml, :to_json_with_active_support_encoder, :to_json_without_active_support_encoder, :to_json, :as_json, :shelljoin, :in_groups_of, :in_groups, :split, :each, :map
		# :inspect,
		delegate *Methods, to: :collection

		def initialize(klass, collection=[])
			@klass = klass
			@collection = collection
		end

		def loaded?
			!!@loaded
		end

		def loaded!
			@loaded = true
		end

		def conditions
			@conditions ||= []
		end

		def collection
			load_data
			@collection
		end

		def reload
			@loaded = false
			load_data
		end
		alias reload! reload

		def load_json
			load_data { |obj| obj }
		end

		def load_data &block
			loaded? || @conditions.blank? and return self

			if klass.is_a?(Model)
				instance_gets klass.resource_name, klass.id, @conditions do |res, req, result, &blk|
					case res.code
					when 200
						loaded!
						return handle_response(res, &block)
					else
						res.return!(req, result, &blk)
					end
				end
			else
				class_get klass.resource_name, @conditions do |res, req, result, &blk|
					case res.code
					when 200
						loaded!
						return handle_response(res, &block)
					else
						res.return!(req, result, &blk)
					end
				end
			end
		end

		def handle_response(response, &blk)
			res = JSON.parse(response)
			results, model = res['results'], res['model']

			_class = Zombie.const_get(model)

			case results
			when Array
				@is_collection = true
				results.each do |obj|
					if block_given?
						@collection << yield(obj)
					else
						@collection << (obj.is_a?(Hash) ? _class.new(obj) : obj)
					end
				end
			when Hash
				@is_collection = false
				block_given? ? yield(results) : @collection << _class.new(results)
			else
				@is_collection = false
				@collection << results
			end
			self.clone
		end

	end
end
