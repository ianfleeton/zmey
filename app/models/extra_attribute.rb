class ExtraAttribute < ApplicationRecord
  validates_uniqueness_of :attribute_name, scope: :class_name

  # Returns 'ClassName#attribute_name'.
  def to_s
    "#{class_name}##{attribute_name}"
  end

  # Returns a hash with three keys.
  #
  # * exists: true if an extra attribute exists for this method
  # * setter: true if method is a setter, false if a getter
  # * attribute_name: name of the attribute, if it exists
  def self.method_info(method_name, class_name)
    attribute_name = method_name.to_s

    if attribute_name[-1] == "="
      attribute_name = attribute_name[0...-1]
      setter = true
    else
      setter = false
    end

    exists = exists?(
      attribute_name: attribute_name, class_name: class_name.to_s
    )

    {
      exists: exists,
      setter: setter,
      attribute_name: attribute_name
    }
  end
end
