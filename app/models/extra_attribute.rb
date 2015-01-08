class ExtraAttribute < ActiveRecord::Base
  validates_uniqueness_of :attribute_name, scope: :class_name

  # Returns 'ClassName#attribute_name'.
  def to_s
    "#{class_name}##{attribute_name}"
  end
end
