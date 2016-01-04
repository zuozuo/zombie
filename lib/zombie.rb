require 'rest-client'
require 'hashie-forbidden_attributes'

require 'zombie/pry'
require 'zombie/dirty'
require 'zombie/version'
require 'zombie/http_helper'
require 'zombie/configurable'

require 'zombie/model'
require 'zombie/collection'

module Zombie
	extend Configurable
  extend ActiveSupport::Concern
	extend HttpHelper

	# included do; end

	def self.const_missing const
		resources = const.to_s.underscore.pluralize
		class_get resources, :_model_structure_ do |res, req, result, &blk|
			res.code != 200 and super(const)

			return Class.new(Zombie::Model).tap do |model|
				self.const_set const, model
				model.model_structure = JSON.parse(res)['results']
			end
		end
	end
end

require 'zombie/api'
