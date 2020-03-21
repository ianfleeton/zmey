class ImageUploader
  attr_reader :failed
  attr_reader :images

  def initialize(params)
    @images = []
    @failed = []

    each_image_from_params(params) do |image|
      yield image if block_given?
      if image.save
        @images << image
      else
        @failed << image
      end
    end
  end

  private

  def each_image_from_params(params)
    original_filename = params[:image].original_filename
    if original_filename[-4, 4].downcase == ".zip"
      count = 0
      ImageUnzipper.new(params[:image].path) do |image_from_zip|
        count += 1
        name = "#{params[:name]} #{count}"
        image_params = params.merge(image: image_from_zip, name: name)
        image = Image.new(image_params)
        yield image
      end
    else
      image = Image.new(params)
      yield image
    end
  end
end
