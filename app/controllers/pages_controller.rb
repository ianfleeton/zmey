class PagesController < ApplicationController
  def show
    @page = Page.find_by(slug: params[:slug], website_id: website)
    if @page
      @title = @page.title
      @description = @page.description
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
    @pages.concat website.pages.reject {|p| p.parent.nil?}
    @pages.concat website.products
    @other_urls = ['/enquiries/new', '/users/forgot_password', '/users/new',
      '/sessions/new', '/basket', '/pages/terms'].collect{|x| 'http://' + website.domain + x}

    respond_to do |format|
      format.xml { render layout: false }
    end
  end
end
