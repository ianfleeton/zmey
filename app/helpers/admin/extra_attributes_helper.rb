module Admin::ExtraAttributesHelper
  # Returns an input field for the given <tt>ExtraAttribute</tt>.
  #
  # The field is prefilled with the value extracted from the <tt>extra</tt>
  # attribute of the object being edited, which is required to be in JSON. It
  # is left blank if the value is not found.
  #
  # Given a Page object and an extra attribute called subheading, returns HTML
  # similar to:
  #
  #   <div class="form-group">
  #     <label for="subheading">Subheading</label>
  #     <input type="text" name="subheading" id="subheading" value="Hello!">
  #   </div>
  def extra_attribute_field(object, extra_attribute)
    attribute_name = extra_attribute.attribute_name
    value = object.extra_json[attribute_name]
    content_tag(:div,
      label_tag(attribute_name, attribute_name.humanize) +
      text_field_tag(attribute_name, value, class: "form-control"),
      class: "form-group")
  end
end
