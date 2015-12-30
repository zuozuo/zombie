module Zombie
	class Collection
		include Zombie::HttpHelper

		attr_reader :klass, :loaded, :collection

		delegate :inspect, :to_s, :==, :eql?, :[], :[]=, :at, :fetch, :first, :last, :concat, :<<, :push, :pop, :shift, :unshift, :insert, :length, :size, :empty?, :find_index, :index, :rindex, :join, :reverse, :reverse!, :rotate, :rotate!, :sort, :sort!, :sort_by!, :collect, :collect!, :select!, :keep_if, :values_at, :delete, :delete_at, :delete_if, :reject, :reject!, :zip, :transpose, :replace, :clear, :fill, :include?, :<=>, :slice, :slice!, :+, :*, :-, :&, :|, :uniq, :uniq!, :compact, :compact!, :flatten, :flatten!, :count, :shuffle!, :shuffle, :sample, :cycle, :permutation, :combination, :repeated_permutation, :repeated_combination, :product, :take, :take_while, :drop, :drop_while, :bsearch, :pack, :append, :prepend, :extract_options!, :blank?, :deep_dup, :to_param, :to_query, :to_sentence, :to_formatted_s, :to_default_s, :to_xml, :to_json_with_active_support_encoder, :to_json_without_active_support_encoder, :to_json, :as_json, :shelljoin, :in_groups_of, :in_groups, :split, to: :collection

		def initialize(klass)
			@klass = klass
			@collection = []
		end

		def loaded?
			!!@loaded
		end

		def loaded!
			@loaded = true
		end

		def conditions
			@conditions ||= {}
		end

		def collection
			load_data
			@collection
		end

		def load_json
			load_data { |obj| obj }
		end

		def zombie_params
			{ methods: @conditions.to_json }
		end

		def load_data &block
			loaded? and return self

			get klass.zombie_path, zombie_params do |res, req, result, &blk|
				case res.code
				when 200
					loaded!
					return handle_response(res, &block)
				else
					res.return!(req, result, &blk)
				end
			end
		end

		def handle_response(response, &blk)
			res = JSON.parse(response)['results']
			case res
			when Array
				res.each do |obj|
					if block_given?
						@collection << yield(obj)
					else
						@collection << (obj.is_a?(Hash) ? klass.new(obj) : obj)
					end
				end
				self.clone
			when Hash
				block_given? ? yield(res) : klass.new(res)
			else
				res
			end
		end

	end
end
