class CustomView < ApplicationRecord
  belongs_to :website

  # Resolver implementation adapted from http://www.justinball.com/2011/09/27/customizing-views-for-a-multi-tenant-application-using-ruby-on-rails-custom-resolvers/

  module ResolverCacheManager
    # Check if the custom_view_cache_count is still the same, if not clear the cache
    def update_website(updated_website)
      clear_cache unless @website.custom_view_cache_count == updated_website.custom_view_cache_count
      @website = updated_website
    end
  end

  # Finds views associated with a website in the database.
  class DatabaseResolver < ActionView::Resolver
    def initialize(website)
      @website = website
      super()
    end

    def find_templates(name, prefix, partial, details)
      path = Path.build(name, prefix, partial)
      conditions = {
        path: path.to_s,
        locale: details[:locale].first,
        format: details[:formats].first,
        handler: details[:handlers],
        partial: partial || false
      }
      @website.custom_views.where(conditions).map do |record|
        handler = ActionView::Template.handler_for_extension(record.handler)
        ActionView::Template.new(record.template, path.to_s, handler,
          virtual_path: record.path,
          format: record.format,
          updated_at: record.updated_at)
      end
    end

    include ResolverCacheManager
  end

  # Find views associated with the website in the theme directory.
  class ThemeResolver < ActionView::FileSystemResolver
    def initialize(website)
      @website = website
      super(File.join(Rails.root, "app", "views", website.theme))
    end

    include ResolverCacheManager
  end
end
