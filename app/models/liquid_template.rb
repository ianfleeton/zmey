class LiquidTemplate < ActiveRecord::Base
  attr_accessible :markup, :name

  def self.new_called(name, website_id)
    lt = LiquidTemplate.new(name: name)
    lt.website_id = website_id
    lt.markup = "<!-- Todo: change this Liquid Template called '#{name}' -->"
    lt.save
    lt
  end
end
