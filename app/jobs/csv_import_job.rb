class CSVImportJob < ApplicationJob
  queue_as :default

  def perform(path, class_name)
    importer = Importers::CSVImporter.new(path, class_name)
    importer.import
  end
end
