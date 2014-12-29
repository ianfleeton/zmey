class ExtraAttribute < ActiveRecord::Base
  # Returns 'ClassName#attribute_name'.
  def to_s
    "#{class_name}##{attribute_name}"
  end
end
