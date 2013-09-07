module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by(login: $1))

    when /the about page/
      pages(:guitar_gear_about).path

    when /the checkout page/
      url_for :controller => 'basket', :action => 'checkout', :only_path => true

    when /the view basket page/
      url_for :controller => 'basket', :only_path => true

    when /the login page/
      url_for :controller => 'sessions', :action => 'new', :only_path => true

    when /the create account page/
      url_for :controller => 'users', :action => 'new', :only_path => true

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
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
