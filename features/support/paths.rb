module NavigationHelpers
  # Maps a static name to a static route.
  #
  # This method is *not* designed to map from a dynamic name to a 
  # dynamic route like <tt>post_comments_path(post)</tt>. For dynamic 
  # routes like this you should *not* rely on #path_to, but write 
  # your own step definitions instead. Example:
  #
  #   Given /I am on the comments page for the "(.+)" post/ |name|
  #     post = Post.find_by_name(name)
  #     visit post_comments_path(post)
  #   end
  #
  def path_to(page_name)
    case page_name
    
    when /the homepage/
      root_path
    
    # Add more page name => path mappings here
    
    when /the checkout page/
      url_for :controller => 'basket', :action => 'checkout', :only_path => true

    when /the view basket page/
      url_for :controller => 'basket', :only_path => true

    when /the login page/
      url_for :controller => 'sessions', :action => 'new', :only_path => true
    
    when /the new page page/
      url_for :controller => 'pages', :action => 'new', :only_path => true

    when /the create page page/
      url_for :controller => 'pages', :action => 'create', :only_path => true

    when /the list websites page/
      url_for :controller => 'websites', :only_path => true
    
    when /the new website page/
      new_website_path

    when /the create website page/
      websites_path

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in features/support/paths.rb"
    end
  end
end

World(NavigationHelpers)
