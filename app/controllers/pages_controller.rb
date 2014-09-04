class PagesController < ApplicationController
  include ShowPage

  def show
    show_page(params[:slug])
  end

  def terms
    @terms = website.terms_and_conditions
  end

  def sitemap
    @pages = Array.new
    @pages.concat website.pages.select(:id, :parent_id, :slug, :website_id).where(no_index: false).where('parent_id IS NOT NULL')
    @pages.concat website.products.select(:id, :name, :website_id)
    @other_urls = ['/enquiries/new', '/users/forgot_password', '/users/new',
      '/sessions/new', '/basket', '/pages/terms'].collect{|x| 'http://' + website.domain + x}

    respond_to do |format|
      format.xml { render layout: false }
    end
  end
end
