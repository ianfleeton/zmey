module Admin
  module SlugHistoriesHelper
    def format_slug_history(website, slug_history)
      content_tag(
        :code,
        "#{h(website.scheme)}://#{h(website.domain)}/".html_safe + content_tag(
          :b, slug_history.slug, class: "slug"
        )
      )
    end
  end
end
