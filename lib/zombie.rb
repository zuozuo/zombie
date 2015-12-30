require 'rest-client'
require 'hashie-forbidden_attributes'

require 'zombie/dirty'
require 'zombie/version'
require 'zombie/http_helper'
require 'zombie/configurable'

require 'zombie/model'
require 'zombie/collection'

if Rails.env.development? || Rails.env.test?
	require 'pry-rails'
	Pry.config.print = proc { |output, value| output.puts "=> #{value.inspect}" } if defined?(Pry)
end

module Zombie
	extend Configurable
  extend ActiveSupport::Concern
	extend HttpHelper

	included do
	end

	# module ClassMethods
		# def model
		# 	model_name.camelcase.constantize
		# end

		# def model_name
		# 	@model_name ||= self.to_s.demodulize.downcase.gsub('api', '')
		# end

		# def resource_name
		# 	self.model_name.pluralize
		# end

		# def source_model(_model_name)
		# 	@model_name = _model_name
		# end

		# def attributes
		# 	@model_attrs ||=
		# 		model.attribute_names.map(&:to_sym) - self.attr_blacklist
		# end

		# def model_attrs(*attrs)
		# 	@model_attrs = attrs.map(&:to_sym) unless attrs.first.to_s == '_all_attrs'
		# end

		# def attr_blacklist
		# 	@attr_blacklist ||= []
		# end

		# def model_attr_black_list(*attrs)
		# 	@attr_blacklist = attrs.map(&:to_sym)
		# end

		# def model_attr_blacklist(*attrs)
		# 	@attr_blacklist = attrs
		# end
	# end

	def self.const_missing const
		resource = const.to_s.underscore.pluralize
		params = { methods: { _model_structure_: [] }.to_json }

		get resource, params do |res, req, result, &blk|
			if res.code == 200
				model = Class.new(Zombie::Model)
				model.model_structure = JSON.parse(res)['results']
				self.const_set const, model
			else
				super(const)
			end
		end
	end
end

require 'zombie/api'
