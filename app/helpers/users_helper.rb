module UsersHelper

  def image_for_admin_status(user) 
    if user.admin? 
      image_tag("iddqd.png", :alt => "Admin", :size => "23x24") 
    end 
  end 

  def gravatar(email_address)
    require 'digest/md5'
    email_address.downcase!
    hash = Digest::MD5.hexdigest(email_address)
    image_src = "http://www.gravatar.com/avatar/#{hash}" + '?d=identicon'
    image_tag(image_src, :alt => 'Gravatar')
  end

end
