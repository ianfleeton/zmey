class LiquidTemplate < ActiveRecord::Base
  belongs_to :website

  validates :name, presence: true, uniqueness: { scope: :website_id }
  validates :website_id, presence: true

  def to_s
    name
  end

  def self.new_called(name, website_id)
    lt = LiquidTemplate.new(name: name)
    lt.website_id = website_id
    lt.markup = "<!-- Todo: change this Liquid Template called '#{name}' -->"
    lt.save
    lt
  end
end
