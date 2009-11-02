class Topic < ActiveRecord::Base
  has_many :posts, :order => 'updated_at asc', :dependent => :destroy
  belongs_to :forum
end
