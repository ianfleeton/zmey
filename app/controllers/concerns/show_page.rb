module ShowPage
  extend ActiveSupport::Concern

  # Shows a page.
  #
  # Carries out the action expected in PagesController#show.
  #
  # This method allows other controllers to fall back on the
  # <tt>pages#show</tt> behaviour when a different resource type is not
  # found.
  #
  # Page slugs can fall back behind predefined routes without being fully
  # shadowed by them.
  #
  # Pages include layout for normal requests but exclude layout for XHR.
  def show_page(slug)
    @page = Page.find_by(slug: slug)
    if @page
      @title = @page.title
      @description = @page.description
      @no_follow = @page.no_follow
      @no_index = @page.no_index
      if request.path == "/"
        @blog = website.blog
      end
      render "pages/show", layout: !request.xhr?
    else
      not_found
    end
  end
end
