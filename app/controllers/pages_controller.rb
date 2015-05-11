class PagesController < ApplicationController
  include ShowPage

  def show
    show_page(params[:slug])
  end

  def terms
    @terms = website.terms_and_conditions
  end

  def sitemap
    pages = Page.select(:id, :parent_id, :slug, :updated_at).where(no_index: false).where('parent_id IS NOT NULL')
    products = Product.select(:id, :name, :updated_at)
    @collections = [pages, products]
    @other_urls = ['/enquiries/new', '/users/forgot_password', '/users/new',
      '/sessions/new', '/basket', '/pages/terms'].collect{|x| website.url + x}

    respond_to do |format|
      format.xml { render layout: false }
    end
  end
end
