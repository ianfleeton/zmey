# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def flash_notice 
    if flash[:notice] 
      content_tag('div', h(flash[:notice]), {:id => "flash_notice"}) 
    end 
  end

  def body_id
    request.host.gsub!('.','-')
  end

  def primary_pages
    Page.find(:all, :conditions => {:website_id => @w})
  end
  
  def truncate(string, length)
    if string.length > length * 1.1
      string[0,length].rstrip + '...'
    else
      string
    end
  end

  def clear
    content_tag('p', '&nbsp;', {:class => 'clear'})
  end
end
