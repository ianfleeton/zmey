module PagesHelper
  def page_edit_table_row(page)
    content_tag(:tr,
      content_tag(:td,
        link_to(page.name, admin_pages_path(parent_id: page.id), class: 'admin-page-nav')
      ) +
      move_up_cell(:move_up_admin_page_path, page) +
      move_down_cell(:move_down_admin_page_path, page) +
      content_tag(
        :td,
        content_tag(
          :div,
          view_button(page, page.path) +
          edit_button([:admin, page]),
          class: 'btn-group'
        ) + ' ' + delete_button([:admin, page])
      )
    )
  end

  # Returns an array of links to the page's ancestors.
  def page_breadcrumbs(page)
    page.ancestors.reverse.map {|p| link_to(p.name, p.path)}
  end
end
