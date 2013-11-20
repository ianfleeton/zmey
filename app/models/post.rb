class Post < ActiveRecord::Base
  belongs_to :topic
  validates_presence_of :content, :author, :email, :topic_id
end
