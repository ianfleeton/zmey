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

  protected

    def object_title(object)
      object.instance_of?(Array) ? object.last : object
    end
end
