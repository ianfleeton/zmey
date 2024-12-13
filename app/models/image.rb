class Image < ApplicationRecord
  include MediaItem

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :pages, dependent: :nullify
  has_many :products, dependent: :nullify
  has_many :product_images, dependent: :delete_all
  has_many :thumbnail_pages, foreign_key: "thumbnail_image_id", class_name: "Page", dependent: :nullify

  def url(size = nil, method = :longest_side, format = :jpg)
    if size.nil?
      url_for_filename(filename)
    else
      sized_url(size, method, format)
    end
  end

  def url_for_filename(f)
    "#{IMAGE_STORAGE_URL}/#{id}/#{f}"
  end

  SIZE_METHODS = [:constrained, :cropped, :height, :longest_side, :width].freeze
  FORMATS = [:webp, :jpg, :png].freeze

  def sized_url(size, method, format = :jpg)
    if (sized = sized_filename(size, method, format))
      url_for_filename(sized)
    else
      "/#{IMAGE_MISSING}"
    end
  end

  def sized_path(size, method, format = :jpg)
    if (sized = sized_filename(size, method, format))
      path_for_filename(sized)
    else
      Image.item_missing_path
    end
  end

  def sized_filename(size, method, format)
    unless SIZE_METHODS.include?(method)
      raise ArgumentError, "method must be one of #{SIZE_METHODS}"
    end

    unless FORMATS.include?(format)
      raise ArgumentError, "format must be one of #{FORMATS}"
    end

    f = sized_item_filename(size, method, format)

    path = File.join(directory_path, f)
    # create a new image of the required size if it doesn't exist
    unless FileTest.exist?(path)
      begin
        image = send(:"size_#{method}", original_image, size)
        image.convert(format).call(destination: path)
      rescue => e
        Rails.logger.warn("Image processing error: #{e}")
        return nil
      end
    end
    f
  end

  def original_image
    raise "Original image missing" unless File.exist?(original_path)
    ImageProcessing::Vips.source(original_path)
  end

  # Returns the path of the missing image file.
  def self.item_missing_path
    File.join(Rails.root.to_s, "public", "images", IMAGE_MISSING)
  end

  # Creates an image using the constrained method.
  def size_constrained(img, size)
    img.resize_to_fit(size[0], size[1])
  end

  # Creates an image using the cropped method.
  def size_cropped(img, size)
    img.resize_to_fill(size[0], size[1])
  end

  # Creates an image using the height method.
  def size_height(img, size)
    img.resize_to_fit(size * 100, size)
  end

  # Creates an image using the longest_side method.
  def size_longest_side(img, size)
    img.resize_to_fit(size, size)
  end

  # Creates an image using the width method.
  def size_width(img, size)
    img.resize_to_fit(size, size * 100)
  end

  # Returns the orginal file data in Base64 encoding.
  # Returns an empty string if the image file is missing or cannot be opened.
  def data_base64
    d = data
    d ? Base64.encode64(d) : ""
  end

  def uploaded_extension
    if @file_data.respond_to?(:original_filename)
      @file_data.original_filename.split(".").last.downcase
    else
      "jpg"
    end
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
