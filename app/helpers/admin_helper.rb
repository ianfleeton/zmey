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
    link_to '<span class="glyphicon glyphicon-edit"></span> Edit'.html_safe,
    edit_polymorphic_path(object),
    class: 'btn btn-default',
    title: "Edit #{object_title(object)}"
  end

  def delete_button(object)
    link_to '<span class="glyphicon glyphicon-trash"></i> Delete'.html_safe,
    object,
    data: { confirm: 'Are you sure?' },
    method: :delete,
    class: 'btn btn-danger btn-default',
    title: "Delete #{object_title(object)}"
  end

  # Provides a button in a table cell to move the object up if it is not
  # already first in the list, or an empty cell if it is.
  def move_up_cell(path_helper, object)
    if object.first?
      content_tag(:td, '&nbsp;'.html_safe)
    else
      content_tag(:td, link_to('Move Up', send(path_helper, object), class: 'btn btn-default'))
    end
  end

  # Provides a button in a table cell to move the object down if it is not
  # already last in the list, or an empty cell if it is.
  def move_down_cell(path_helper, object)
    if object.last?
      content_tag(:td, '&nbsp;'.html_safe)
    else
      content_tag(:td, link_to('Move Down', send(path_helper, object), class: 'btn btn-default'))
    end
  end

  protected

    def object_title(object)
      object.instance_of?(Array) ? object.last : object
    end
end
