# frozen_string_literal: true

class WebKitHTMLToPDF
  # Returns the appropriate wkhtmltopdf binary for the current platform.
  def self.binary
    "wkhtmltopdf"
  end
end
