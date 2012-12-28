module AdminHelper
  def page_header(title)
    content_tag(:h1, title, class: 'page-header')
  end

  def edit_button(object)
    link_to '<i class="icon-edit"></i> Edit'.html_safe,
    edit_polymorphic_path(object),
    class: 'btn btn-mini'
  end

  def delete_button(object)
    link_to '<i class="icon-trash icon-white"></i> Delete'.html_safe,
    object,
    data: { confirm: 'Are you sure?' },
    method: :delete,
    class: 'btn btn-danger btn-mini'
  end
end
