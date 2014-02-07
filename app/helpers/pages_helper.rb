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
          link_to(page.name, page.path) + ' '.html_safe
        ) +
        edit_page(page) +
        move_up_cell(:move_up_admin_page_path, page) +
        move_down_cell(:move_down_admin_page_path, page) +
        delete_page(page)
    )
  end

  def edit_page(page)
    content_tag(:td, edit_button([:admin, page]))
  end

  def delete_page(page)
    content_tag(:td, delete_button([:admin, page]))
  end
end
