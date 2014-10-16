module AdminHelper
  def admin_menu_links(links)
    links.map { |text, path| admin_menu_link(text, path) }.join.html_safe
  end

  def admin_menu_link(text, path)
    content_tag(
      :li,
      link_to(text, path),
      current_page?(path) ? { class: 'active' } : {}
    )
  end

  def page_header(title)
    content_tag(:div, content_tag(:h1, title), class: 'page-header')
  end

  def breadcrumbs(crumbs, heading)
    content_tag(:ol,
      crumbs.map {|k,v| content_tag(:li, link_to(k,v)) }.join.html_safe +
      content_tag(:li, heading, class: 'active'),
      class: 'breadcrumb'
    )
  end

  def new_button(type)
    link_to '<span class="glyphicon glyphicon-plus"></span> New'.html_safe,
    new_polymorphic_path(type),
    class: 'btn btn-default',
    title: "New #{object_title(type)}"
  end

  # Renders a button to view an object. If <tt>link</tt> is supplied then this
  # is used for the hyperlink, otherwise the link is determined from the object.
  def view_button(object, link = nil)
    link_to '<span class="glyphicon glyphicon-eye-open"></span> View'.html_safe,
    link ? link : polymorphic_path(object),
    class: 'btn btn-default',
    title: "View #{object_title(object)}"
  end

  def edit_button(object)
    link_to icon_edit,
    edit_polymorphic_path(object),
    class: 'btn btn-default',
    title: "Edit #{object_title(object)}"
  end

  def delete_button(object)
    link_to icon_delete,
    object,
    data: { confirm: 'Are you sure?' },
    method: :delete,
    class: 'btn btn-danger btn-default',
    title: "Delete #{object_title(object)}"
  end

  # Provides a button to move the object up if it is not
  # already first in the list, or an empty string if it is.
  def move_up_button(path_helper, object)
    if object.first?
      ''.html_safe
    else
      link_to(icon_up, send(path_helper, object), title: 'Move Up', class: 'btn btn-default').html_safe
    end
  end

  # Provides a button to move the object down if it is not
  # already last in the list, or an empty string if it is.
  def move_down_button(path_helper, object)
    if object.last?
      ''.html_safe
    else
      link_to(icon_down, send(path_helper, object), title: 'Move Down', class: 'btn btn-default').html_safe
    end
  end

  def icon_delete
    '<span class="glyphicon glyphicon-trash"></span>'.html_safe
  end

  def icon_down
    '<span class="glyphicon glyphicon-arrow-down"></span>'.html_safe
  end

  def icon_edit
    '<span class="glyphicon glyphicon-edit"></span>'.html_safe
  end

  def icon_up
    '<span class="glyphicon glyphicon-arrow-up"></span>'.html_safe
  end

  def icon_remove
    '<span class="glyphicon glyphicon-remove"></span>'.html_safe
  end

  protected

    def object_title(object)
      object.instance_of?(Array) ? object.last : object
    end
end
