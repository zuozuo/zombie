module Test
  module V1
    class UserApi < Grape::API
      version 'v1', using: :path
      format :json
      prefix :api
      include Zombie

    end
  end
end
