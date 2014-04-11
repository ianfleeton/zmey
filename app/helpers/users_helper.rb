module UsersHelper

  def gravatar(email_address)
    require 'digest/md5'
    email_address.downcase!
    hash = Digest::MD5.hexdigest(email_address)
    image_src = "http://www.gravatar.com/avatar/#{hash}" + '?d=identicon'
    image_tag(image_src, alt: 'Gravatar')
  end

end
