require "csv"

class Admin::ExportController < Admin::AdminController
  CLASSES = %w[Product]

  def index
    @classes = CLASSES
  end

  def csv
    exporter = CSVExporter.new(params[:class_name])

    csv_string = exporter.generate

    Mime::Type.register "text/csv", :csv
    expires_now
    send_data csv_string, type: :csv, filename: exporter.filename
  end
end
