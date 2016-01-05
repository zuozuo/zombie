class User < ActiveRecord::Base
  has_many :posts

  scope :posts, -> { Post.all }

  def self.test_method
  end

  def self.create_with_user
    User.new
  end

  def all_posts
    self.posts
  end
end
