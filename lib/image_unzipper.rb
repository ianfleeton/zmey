class ImageUnzipper
  def initialize(zip_file)
    zip_dir = "#{Rails.root}/tmp/#{SecureRandom.hex}"
    zip_path = "#{zip_dir}/#{File.basename(zip_file)}"
    FileUtils.makedirs(zip_dir)
    FileUtils.cp(zip_file, zip_path)
    `unzip #{zip_path} -d #{zip_dir}`
    Dir.entries(zip_dir).select{|f|File.file?("#{zip_dir}/#{f}") && image?(f)}.each do |f|
      yield ImageFromZip.new("#{zip_dir}/#{f}")
    end
  ensure
    FileUtils.rm_rf(zip_dir)
  end

  # Provides a similar interface to an uploaded file.
  class ImageFromZip
    def initialize(path)
      @path = path
    end

    def read
      IO.read(@path)
    end

    def original_filename
      File.basename(@path)
    end
  end

  private

    def image?(filename)
      ['.jpg', '.png'].include?(filename[-4, 4].downcase)
    end
end
