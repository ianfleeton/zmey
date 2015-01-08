module ExtraAttributes
  extend ActiveSupport::Concern

  # Returns the <tt>extra</tt> attribute parsed as JSON.
  def extra_json
    @extra_json ||= JSON.parse(extra || '{}')
  end

  # Clear memoized values.
  def reload
    @extra_json = nil
    super
  end

  # Updates the <tt>extra</tt> attribute with values in the hash, adding new
  # entries as necessary.
  #
  # Keys that missing from ExtraAttributes are ignored.
  #
  # Entries that already exist in <tt>extra</tt> but are not included in the
  # hash are preserved.
  #
  # Returns <tt>true</tt> if <tt>extra</tt> was changed.
  def update_extra(hash)
    changed = false
    hash.each_pair do |k,v|
      changed = true if set_extra_attribute(k, v)
    end

    changed
  end

  # Provides setters and getters for extra attributes.
  #
  # ==== Example
  #   ExtraAttribute.create(attribute_name: 'subhead', class_name: 'Page')
  #   page = Page.new
  #   page.subhead = 'Subheading'
  #   page.subhead # => 'Subheading'
  def method_missing(method_sym, *arguments, &block)
    method_str = method_sym.to_s

    if method_str[-1] == '='
      method_str = method_str[0...-1]
      setter = true
    else
      setter = false
    end

    if ExtraAttribute.exists?(attribute_name: method_str, class_name: self.class)
      if setter
        set_extra_attribute(method_str, arguments[0])
      else
        extra_json[method_str]
      end
    else
      super
    end
  end

  private

    # Sets a single extra attribute if it exists.
    #
    # Returns a truthy value if the attribute exists.
    def set_extra_attribute(attribute_name, value)
      if ExtraAttribute.exists?(attribute_name: attribute_name, class_name: self.class)
        extra_json[attribute_name] = value
        self.extra = extra_json.to_json
      end
    end
end
