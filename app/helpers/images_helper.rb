module ImagesHelper
  def image_options
    [['No image', nil]] +
      Image.find(
        :all,
        :select => 'id, name',
        :conditions => ['website_id = ?', @w.id],
        :order => :name).map {|i| [i.name, i.id]}
  end
end