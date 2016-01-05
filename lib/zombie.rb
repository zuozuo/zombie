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

	# included do
	# 	# alias _old_scope_ scope
	# end

	# module ClassMethods
	# 	def scope(name, scope_options = {})
	# 		_old_scope_(name, scope_options)
	# 	end
	# 	
	# 	# def zombie_
	# 	# end
	# end
	
	def self.const_missing const
		res = class_get const.to_s.underscore.pluralize, :_model_structure_
		res and return Class.new(Zombie::Model).tap do |model|
			self.const_set const, model
			model.model_structure = res
		end
	end
end

require 'zombie/api'
