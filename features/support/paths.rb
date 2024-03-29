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
    #     user_profile_path(User.find_by_login($1))

    when /the shop (.+)'s edit page/
      shop = Shop.find_by_name($1)
      "/shops/#{shop.to_param}/edit"
    
    when /the signup page/
      '/register'   
    
    when /the login page/
      '/login'
  
    when /path "(.+)"/
      $1
    
    when /the show page for (.+)/
      polymorphic_path(model($1))        
    
    when /^the ordering screen for (.*)$/
      shop = Shop.find_by_name($1)
      "/shops/#{shop.to_param}/orders/new"  

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
