module PagesHelper
  def indent_tag indent
    ('<span class="indent">&nbsp; &nbsp;</span>' * indent).html_safe
  end

  def page_tree p, indent = 0
    subs = ''
    unless p.children.empty?
      p.children.each do |c|
        subs += page_tree c, indent+1
      end
    end
    edit = content_tag(:td, edit_button([:admin, p]))
    delete = content_tag(:td, delete_button([:admin, p]))

    if p.first?
      move_up = content_tag(:td, '&nbsp;'.html_safe)
    else
      move_up = content_tag(:td, link_to('Move Up', move_up_admin_page(p), class: 'btn btn-mini'))
    end

    if p.last?
      move_down = content_tag(:td, '&nbsp;'.html_safe)
    else
      move_down = content_tag(:td, link_to('Move Down', move_down_admin_page(p), class: 'btn btn-mini'))
    end

    content_tag(:tr,
      content_tag(:td, 
        indent_tag(indent) +
          link_to(p.name, p.path) + ' '.html_safe +
          edit +
          delete +
          move_up +
          move_down
      )
    ) + subs.html_safe
  end
end
