module Zombie
	class Collection
		include Zombie::HttpHelper

		attr_reader :collection, :callstack, :klass, :loaded

		delegate :inspect, :to_s, :==, :eql?, :[], :[]=, :at, :fetch, :first, :last, :concat, :<<, :push, :pop, :shift, :unshift, :insert, :length, :size, :empty?, :find_index, :index, :rindex, :join, :reverse, :reverse!, :rotate, :rotate!, :sort, :sort!, :sort_by!, :collect, :collect!, :select!, :keep_if, :values_at, :delete, :delete_at, :delete_if, :reject, :reject!, :zip, :transpose, :replace, :clear, :fill, :include?, :<=>, :slice, :slice!, :+, :*, :-, :&, :|, :uniq, :uniq!, :compact, :compact!, :flatten, :flatten!, :count, :shuffle!, :shuffle, :sample, :cycle, :permutation, :combination, :repeated_permutation, :repeated_combination, :product, :take, :take_while, :drop, :drop_while, :bsearch, :pack, :append, :prepend, :extract_options!, :blank?, :deep_dup, :to_param, :to_query, :to_sentence, :to_formatted_s, :to_default_s, :to_xml, :to_json_with_active_support_encoder, :to_json_without_active_support_encoder, :to_json, :as_json, :from, :to, :second, :third, :fourth, :fifth, :forty_two, :shelljoin, :in_groups_of, :in_groups, :split, to: :collection

		def initialize(klass)
			@klass = klass
			@callstack = []
			@collection = []
		end

		def conditions
			@conditions ||= {}
		end

		def inspect
			# load_data
			@collection.inspect
		end

		def load_data
			unless loaded?
				get klass.zombie_path, zombie_params do |res, req, result, &blk|
					case res.code
					when 200
						handle_response(res)
					else
						response.return!(req, result, &blk)
					end
				end
				loaded!
			end
			self
		end

		def handle_response(response)
			binding.pry
			res = JSON.parse(response)
			case res
			when Array
				@collection = res.map { |obj| klass.new(obj) }
				return self
			when Hash
				return klass.new(Hash)
			else
				raise InvalidResponse.new(response)
			end
		end

		def zombie_params
			{ methods: @conditions.to_json }
		end

		# def load_json
		# 	self
		# end

		def loaded?
			!!@loaded
		end

		def loaded!
			@loaded = true
		end

		# def method_missing(meth, *args, &blk)
		# 	@callstack << "#{meth}(#{args.join(', ')}) called at #{__FILE__}:#{__LINE__}"

		# 	conditions[meth] = args
		# 	self.clone
		# end

	end
end
