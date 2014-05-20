class Image < ActiveRecord::Base
  validates_presence_of :name, :website_id
  validates_uniqueness_of :name, scope: :website_id

  belongs_to :website

  has_many :carousel_slides, dependent: :restrict_with_exception
  has_many :pages, dependent: :nullify
  has_many :products, dependent: :nullify

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
    if @file_data
      self.filename = "image.#{uploaded_extension}"
    end
  end

  # write the @file_data data content to disk,
  # using the IMAGE_STORAGE_PATH constant.
  # saves the file with the filename of the model id
  # together with the file original extension
  def write_file
    if @file_data
      @file_data.rewind
      # remove any existing images (which may have different extensions)
      delete_files
      path = "#{IMAGE_STORAGE_PATH}/#{id}"
      FileUtils.makedirs(path)
      File.open(path + '/' + filename, "wb") { |file| file.write(@file_data.read) }
    end
  end

  def url(size=nil)
    if size.nil?
      f = filename
    else
      f = 'sized_' + size.to_s + '.' + extension
      path = "#{IMAGE_STORAGE_PATH}/#{id}/#{f}"
      # create a new image of the required size if it doesn't exist
      unless FileTest.exists?(path)
        begin
          ImageScience.with_image("#{IMAGE_STORAGE_PATH}/#{id}/#{filename}") do |img|
            # protect against crashes
            if img.height <= 1 || img.width <= 1
              return IMAGE_MISSING
            end

            img.thumbnail(size) do |thumb|
              thumb.save path
            end
          end
        rescue
          return IMAGE_MISSING
        end
      end
    end
    "#{IMAGE_STORAGE_URL}/#{id}/#{f}"
  end

  # deletes the file(s) by removing the whole dir
  def delete_files
    FileUtils.rm_rf("#{IMAGE_STORAGE_PATH}/#{id}")
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
end
