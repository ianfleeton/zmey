module ExtraAttributes
  extend ActiveSupport::Concern

  # Returns the <tt>extra</tt> attribute parsed as JSON.
  def extra_json
    @extra_json ||= JSON.parse(extra || '{}')
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
      if ExtraAttribute.exists?(attribute_name: k, class_name: self.class)
        extra_json[k] = v
        changed = true
      end
    end
    self.extra = extra_json.to_json if changed

    changed
  end
end
