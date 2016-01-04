# if Rails.env.development? || Rails.env.test?
# 	require 'pry-rails'
#   Pry.config.print = proc do |output, value, _pry_|
#     _pry_.pager.open do |pager|
#       pager.print _pry_.config.output_prefix
# 			# value.load_data if value.is_a?(Zombie::Collection)
#       Pry::ColorPrinter.pp(value, pager, Pry::Terminal.width! - 1)
#     end
#   end
# end
