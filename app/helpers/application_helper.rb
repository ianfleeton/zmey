# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def primary_pages
    Page.find(:all, :conditions => {:website_id => @website})
  end
end
