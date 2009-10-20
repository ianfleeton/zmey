module PagesHelper
  def indent_tag indent
    '' + content_tag(:span, '&nbsp; &nbsp;', :class => 'indent') * indent
  end
  def page_tree p, indent = 0
    subs = ''
    unless p.children.empty?
      p.children.each do |c|
        subs += page_tree c, indent+1
      end
    end
    edit = content_tag(:td, link_to('Edit', :controller => 'pages', :action => 'edit', :id => p.id))

    if p.first?
      move_up = content_tag(:td, '&nbsp;')
    else
      move_up = content_tag(:td, link_to('Move Up', :controller => 'pages', :action => 'move_up', :id => p.id))
    end

    if p.last?
      move_down = content_tag(:td, '&nbsp;')
    else
      move_down = content_tag(:td, link_to('Move Down', :controller => 'pages', :action => 'move_down', :id => p.id))
    end

    content_tag(:tr,
      content_tag(:td, 
        indent_tag(indent) +
          link_to(h(p.name), page_url(p)) + ' ' +
          edit +
          move_up +
          move_down
      )
    ) + subs
  end
end
