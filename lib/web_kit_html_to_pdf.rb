class WebKitHTMLToPDF
  def self.binary
    RUBY_PLATFORM.include?('darwin') ? './wkhtmltopdf-macosx' : './wkhtmltopdf-i386'
  end
end
