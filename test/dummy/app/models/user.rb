class User < ActiveRecord::Base
  has_many :posts

  def self.posts
    Post.all
  end
end
