module UsersHelper

  def image_for_admin_status(user) 
    if user.admin? 
      image_tag("iddqd.png", :alt => "Admin", :size => "23x24") 
    end 
  end 


end
