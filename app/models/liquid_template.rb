class LiquidTemplate < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  def to_s
    name
  end

  def self.new_called(name)
    lt = LiquidTemplate.new(name: name)
    lt.markup = "<!-- Todo: change this Liquid Template called '#{name}' -->"
    lt.save
    lt
  end
end
