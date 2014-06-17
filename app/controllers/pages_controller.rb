class PagesController < ApplicationController
  def show
    @page = Page.find_by(slug: params[:slug], website_id: website)
    if @page
      @title       = @page.title
      @description = @page.description
      @no_follow   = @page.no_follow
      @no_index    = @page.no_index
      if request.path == '/'
        @blog = website.blog
      end
    else
      not_found
    end
  end

  def terms
    @terms = website.terms_and_conditions
  end

  def sitemap
    @pages = Array.new
    @pages.concat website.pages.where(no_index: false).reject {|p| p.parent.nil?}
    @pages.concat website.products.select(:id, :name, :website_id)
    @other_urls = ['/enquiries/new', '/users/forgot_password', '/users/new',
      '/sessions/new', '/basket', '/pages/terms'].collect{|x| 'http://' + website.domain + x}

    respond_to do |format|
      format.xml { render layout: false }
    end
  end
end
