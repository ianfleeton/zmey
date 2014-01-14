class ImageUploader
  attr_reader :failed
  attr_reader :images

  def initialize(params)
    @images = []
    @failed = []
    image = Image.new(params)
    yield image if block_given?
    if image.save
      @images << image
    else
      @failed << image
    end
  end
end
