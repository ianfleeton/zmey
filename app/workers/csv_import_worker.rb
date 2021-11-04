# frozen_string_literal: true

class CSVImportWorker
  include Sidekiq::Worker

  def perform(path, class_name)
    importer = Importers::CSVImporter.new(path, class_name)
    importer.import
  end
end
