class WebKitHTMLToPDF
  # Returns the appropriate wkhtmltopdf binary for the current platform.
  def self.binary
    linux_binaries = Hash.new('wkhtmltopdf')
    linux_binaries['i686-linux'] = './wkhtmltopdf-i386'

    ruby_platform.include?('darwin') ? './wkhtmltopdf-macosx' : linux_binaries[ruby_platform]
  end

  def self.ruby_platform
    RUBY_PLATFORM
  end
end
