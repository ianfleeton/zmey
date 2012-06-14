class Post < ActiveRecord::Base
  attr_accessible :author, :content, :email

  validates_presence_of :content, :author, :email
end
