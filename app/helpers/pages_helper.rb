module PagesHelper
  def page_edit_table_row(page)
    content_tag(:tr,
      content_tag(:td,
        link_to(page.name, admin_pages_path(parent_id: page.id), class: 'admin-page-nav')
      ) +
      content_tag(
        :td,
        content_tag(
          :div,
          page_move_buttons(page) +
          view_button(page, page.path) +
          edit_button([:admin, page]),
          class: 'btn-group'
        ) + ' ' + delete_button([:admin, page])
      )
    )
  end

  def page_move_buttons(page)
    if page.parent_id.nil?
      ''.html_safe
    else
      move_up_button(:move_up_admin_page_path, page) +
      move_down_button(:move_down_admin_page_path, page)
    end
  end

  # Returns an array of links to the page's ancestors.
  def page_breadcrumbs(page)
    page.ancestors.reverse.map {|p| link_to(p.name, p.path)}
  end

  # Returns a cache key for the collection of all pages.
  def pages_cache_key
    [
      Page.count,
      Page.order('updated_at DESC').first
    ]
  end
end
