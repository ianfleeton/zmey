module MediaItem
  extend ActiveSupport::Concern

  included do
    validates_presence_of :name
    validates_uniqueness_of :name, case_sensitive: false

    before_save :determine_filename
    after_save :write_file
    after_destroy :delete_files
  end

  def file=(file_data)
    @file_data = file_data unless file_data.is_a?(String) && file_data.empty?
  end

  def slug
    self.class.to_s.downcase
  end

  def determine_filename
    if defined?(@file_data) && @file_data
      self.filename = "#{slug}.#{uploaded_extension}"
    end
  end

  # Write the @file_data data content to disk,
  # using storage_path.
  # Saves the file with the filename of the model id
  # together with the file original extension.
  # Updates the MD5 hash.
  def write_file
    if defined?(@file_data) && @file_data
      @file_data.rewind
      # remove any existing images (which may have different extensions)
      delete_files
      FileUtils.makedirs(directory_path)
      File.open(original_path, "wb") do |file|
        data = @file_data.read
        update_column(:md5_hash, Digest::MD5.hexdigest(data))
        file.write(data)
      end
      @file_data = nil
      after_write_file
    end
  end

  def after_write_file
  end

  # Returns the path of the directory that the local file is stored in.
  def directory_path
    File.join(storage_path, id.to_s)
  end

  # Returns the path of the original local image.
  def original_path
    File.join(directory_path, filename)
  end

  # Returns the full local path to the item with filename <tt>f</tt>.
  def path_for_filename(f)
    File.join(directory_path, f)
  end

  # Returns the raw file data for the original item.
  # Returns nil if the image file is missing or cannot be opened.
  def data
    File.binread(original_path)
  rescue
    nil
  end

  # deletes the file(s) by removing the whole dir
  def delete_files
    FileUtils.rm_rf(directory_path)
  end

  # Returns a filename to use for a sized item.
  #
  #   i = Image.new(filename: 'image.jpg')
  #   i.sized_image_filename(100, :longest_side) # => "longest_side.100.jpg"
  def sized_item_filename(size, method)
    method.to_s + "." + size.to_s.gsub(", ", "x").delete("[").delete("]") + "." + extension
  end

  def extension
    e = filename.split(".").last
    e = "" if e.nil?
    e
  end

  def storage_url
    "/up/#{storage_slug}#{"-test" if Rails.env.test?}"
  end

  def storage_path
    "#{::Rails.root}/public/up/#{storage_slug}#{"-test" if Rails.env.test?}"
  end

  def storage_slug
    slug.pluralize
  end

  class_methods do
    # Returns the sized path for image <tt>id</tt>. The method and size is parsed
    # from the <tt>filename</tt>.
    #
    # Returns the path of the <tt>IMAGE_MISSING</tt> file if the image does not
    # exist.
    def sized_path(id, filename)
      if (image = find_by(id: id)) && (properties = parse_filename(filename))
        image.sized_path(properties[:size], properties[:method])
      else
        item_missing_path
      end
    end

    # Returns a hash describing the sizing method and size of the sized image.
    # <tt>nil</tt> is returned if the <tt>filename</tt> is invalid.
    #
    #   Image.parse_filename('longest_side.100.jpg')
    #   # => {method: :longest_side, size: 100}
    #
    #   Image.parse_filename('cropped.640x480.jpg')
    #   # => {method: :cropped, size: [640,480]}
    def parse_filename(filename)
      if (match = filename.match(/([a-z_]+)\.(\d+)\.[a-z]+/))
        {method: match[1].to_sym, size: match[2].to_i}
      elsif (match = filename.match(/([a-z_]+)\.(\d+)x(\d+)\.[a-z]+/))
        {method: match[1].to_sym, size: [match[2].to_i, match[3].to_i]}
      end
    end

    # Deletes all files of this media type.
    def delete_files
      FileUtils.rm_rf(storage_path)
      FileUtils.makedirs(storage_path)
    end
  end
end
