require 'csv'

class CSVImporter < Importer
  def initialize(csv_file, class_name)
    super(class_name)
    @csv_file = csv_file
  end

  def import
    lines = CSV.read(@csv_file, headers: true, encoding: 'UTF-8')
    super(lines)
  end
end
