class Image < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :carousel_slides, dependent: :restrict_with_exception
  has_many :pages, dependent: :nullify
  has_many :products, dependent: :nullify
  has_many :thumbnail_pages, foreign_key: 'thumbnail_image_id', class_name: 'Page', dependent: :nullify

  before_save   :determine_filename
  after_save    :write_file
  after_destroy :delete_files

  liquid_methods :name

  def image=(file_data)
    unless file_data.kind_of? String and file_data.empty?
      @file_data = file_data
    end
  end

  def determine_filename
    if defined?(@file_data) && @file_data
      self.filename = "image.#{uploaded_extension}"
    end
  end

  # write the @file_data data content to disk,
  # using the IMAGE_STORAGE_PATH constant.
  # saves the file with the filename of the model id
  # together with the file original extension
  def write_file
    if defined?(@file_data) && @file_data
      @file_data.rewind
      # remove any existing images (which may have different extensions)
      delete_files
      FileUtils.makedirs(directory_path)
      File.open(original_path, "wb") { |file| file.write(@file_data.read) }
    end
  end

  # Returns the path of the directory that the local file is stored in.
  def directory_path
    File.join(IMAGE_STORAGE_PATH, id.to_s)
  end

  # Returns the path of the original local image.
  def original_path
    File.join(directory_path, filename)
  end

  def url(size=nil, method=:longest_side)
    if size.nil?
      url_for_filename(filename)
    else
      sized_url(size, method)
    end
  end

  def url_for_filename(f)
    "#{IMAGE_STORAGE_URL}/#{id}/#{f}"
  end

  SIZE_METHODS = [:constrained, :height, :longest_side, :maxpect, :square, :width].freeze

  def sized_url(size, method)
    unless SIZE_METHODS.include?(method)
      raise ArgumentError.new("method must be one of #{SIZE_METHODS}")
    end

    f = sized_image_filename(size, method)

    path = File.join(directory_path, f)
    # create a new image of the required size if it doesn't exist
    unless FileTest.exist?(path)
      begin
        ImageScience.with_image(original_path) do |img|
          # protect against crashes
          if img.height <= 1 || img.width <= 1
            return IMAGE_MISSING
          end

          send("size_#{method}", img, size, path)
        end
      rescue
        return IMAGE_MISSING
      end
    end
    url_for_filename(f)
  end

  # Returns a filename to use for a sized image.
  #
  #   i = Image.new(filename: 'image.jpg')
  #   i.sized_image_filename(100, :longest_side) # => "longest_side_100.jpg"
  def sized_image_filename(size, method)
    method.to_s + '_' + size.to_s.gsub(", ", 'x').gsub('[', '').gsub(']', '') + '.' + extension
  end

  # Creates an image using the constrained method and writes it to
  # <tt>path</tt>.
  def size_constrained(img, size, path)
    target_aspect_ratio = size[0].to_f / size[1].to_f
    src_aspect_ratio = img.width.to_f / img.height.to_f
    if src_aspect_ratio > target_aspect_ratio
      size_width(img, size[0], path)
    else
      size_height(img, size[1], path)
    end
  end

  # Creates an image using the height method and writes it to
  # <tt>path</tt>.
  def size_height(img, size, path)
    img.resize(img.width * size / img.height, size) do |thumb|
      thumb.save path
    end
  end

  # Creates an image using the longest_side method and writes it to
  # <tt>path</tt>.
  def size_longest_side(img, size, path)
    img.thumbnail(size) do |thumb|
      thumb.save(path)
    end
  end

  # Creates an image using the maxpect method and writes it to
  # <tt>path</tt>.
  def size_maxpect(img, size, path)
    if size.kind_of? Array
      width = size[0]
      height = size[1]
    else
      width = height = size
    end

    src_ar = img.width.to_f / img.height.to_f
    thumb_ar = width.to_f / height.to_f
    tolerance = 0.1
    if(src_ar * (1+tolerance) < thumb_ar || src_ar / (1+tolerance) > thumb_ar)
      if(src_ar > thumb_ar)
        height = (width / src_ar).to_i
      else
        width = (height * src_ar).to_i
      end
    end
    img.resize(width, height) do |thumb|
      thumb.save(path)
    end
  end

  # Creates an image using the square method and writes it to
  # <tt>path</tt>.
  def size_square(img, size, path)
    img.cropped_thumbnail(size) do |thumb|
      thumb.save path
    end
  end

  # Creates an image using the width method and writes it to
  # <tt>path</tt>.
  def size_width(img, size, path)
    img.resize(size, img.height * size / img.width) do |thumb|
      thumb.save path
    end
  end

  # Returns the orginal file data in Base64 encoding.
  # Returns an empty string if the image file is missing or cannot be opened.
  def data_base64
    d = data
    d ? Base64::encode64(d) : ''
  end

  # Returns the raw file data for the original image.
  # Returns nil if the image file is missing or cannot be opened.
  def data
    begin
      File.open(original_path, 'rb') { |f| f.read }
    rescue
      nil
    end
  end

  # deletes the file(s) by removing the whole dir
  def delete_files
    FileUtils.rm_rf(directory_path)
  end

  def uploaded_extension
    if @file_data.respond_to?(:original_filename)
      @file_data.original_filename.split(".").last.downcase
    else
      'jpg'
    end
  end

  def extension
    e = filename.split(".").last
    e = '' if e.nil?
    e
  end

  def to_webhook_payload(event)
    {
      image: {
        id: id,
        url: "#{Website.first.url}#{url}"
      }
    }
  end

  def self.fast_delete_all
    raise ActiveRecord::DeleteRestrictionError.new('carousel_slides') if CarouselSlide.any?

    Page.where.not(image_id: nil).update_all(image_id: nil, updated_at: Time.zone.now)
    Page.where.not(thumbnail_image_id: nil).update_all(thumbnail_image_id: nil, updated_at: Time.zone.now)
    Product.where.not(image_id: nil).update_all(image_id: nil, updated_at: Time.zone.now)

    Image.delete_all

    delete_files
  end

  def self.delete_files
    FileUtils.rm_rf(IMAGE_STORAGE_PATH)
    FileUtils.makedirs(IMAGE_STORAGE_PATH)
  end
end
