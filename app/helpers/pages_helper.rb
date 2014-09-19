module PagesHelper
  def indent_tag indent
    ('<span class="indent">&nbsp; &nbsp;</span>' * indent).html_safe
  end

  def page_tree(p, indent=0, &block)
    subs = ''
    unless p.children.empty?
      p.children.each do |c|
        subs += page_tree(c, indent+1, &block)
      end
    end

    capture(p, indent, &block) + subs.html_safe
  end

  def page_edit_table_row(page, indent)
    content_tag(:tr,
      content_tag(:td, 
        indent_tag(indent) +
        page.name
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
