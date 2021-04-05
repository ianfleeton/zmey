class Administrator < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :registerable, :timeoutable and :omniauthable
  devise :database_authenticatable,
    :recoverable, :rememberable, :trackable, :validatable

  # Validations
  validates_length_of :email, maximum: 191
  validates_presence_of :name

  # Returns the administrator's name.
  def to_s
    name
  end
end
