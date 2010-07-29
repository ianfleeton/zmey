# coding: utf-8
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def flash_notice
    notice = ''
    if flash[:now]
      notice = flash[:now]
      flash[:now] = nil
    end
    if flash[:notice]
      notice += ' ' + flash[:notice]
    end
    unless notice.empty?
      content_tag('div', h(notice), {:id => "flash_notice"})
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
  
  def a_tick
    '<span class="tick">✔</span>'
  end
  
  def a_cross
    '<span class="cross">✘</span>'
  end
  
  def tick_cross yes, show_cross=true
    if yes
      a_tick
    elsif show_cross
      a_cross
    end
  end
  
  def tick yes
    tick_cross yes, false
  end
  
  def nav_link_to name, options = {}, html_options = nil, class_name = ''
    class_name = 'n_' + name.downcase.gsub(' ', '_') if class_name.empty?
    if current_page? options
      class_name += ' n_current'
      content_tag(:li, name, :class => class_name)
    else
      content_tag(:li, link_to(name, options, html_options), :class => class_name)
    end
  end

  def format_date d
    if (Time.now - d) < 2.minutes
      'Just a moment ago'
    elsif (Time.now - d) < 1.hours
      ((Time.now - d)/60).ceil.to_s + ' minutes ago'
    elsif d.today?
      'Today at ' + d.strftime("%l:%M%p").downcase
    elsif (d+1.day).today?
      'Yesterday at ' + d.strftime("%l:%M%p").downcase
    elsif (Time.now - d) < 1.week
      d.strftime('%A at ') + d.strftime("%l:%M%p").downcase
    elsif d.year == Time.now.year
      d.strftime("%e %b at ") + d.strftime("%l:%M%p").downcase
    else
      d.strftime("%e %b %Y at ") + d.strftime("%l:%M%p").downcase
    end
  end
end
