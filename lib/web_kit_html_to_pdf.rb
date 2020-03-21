class WebKitHTMLToPDF
  # Returns the appropriate wkhtmltopdf binary for the current platform.
  def self.binary
    ruby_platform.include?("darwin") ? "./wkhtmltopdf-macosx" : "wkhtmltopdf"
  end

  def self.ruby_platform
    RUBY_PLATFORM
  end
end
