module Importers
  # Imports data from an array of hashes (key value pairs) into the database.
  # Provides both creation of new records and updating of existing records.
  class Importer
    DO_NOT_IMPORT = "DO-NOT-IMPORT"

    attr_reader :current_row

    def initialize(class_name)
      @klass = Kernel.const_get(class_name)
      reset
    end

    def import(rows)
      reset
      rows.each { |row| import_row(row) }
    end

    def error_text
      @errors.join("\n").truncate(64_000)
    end

    def import_row(row)
      @current_row += 1

      if (object = find_object(row))
        update_object(object, row)
      else
        create_object(row)
      end
    end

    def importable_attributes
      @attrs ||= @klass.respond_to?(:importable_attributes) ? @klass.importable_attributes : @klass.attribute_names
    end

    def find_object(row)
      @klass.find_by(import_id => row[import_id])
    end

    def import_id
      @import_id ||= @klass.respond_to?(:import_id) ? @klass.import_id : "id"
    end

    private

    def reset
      @current_row = 1
      @errors = []
    end

    def update_object(object, row)
      update_fail(row) unless object.update(attributes(row))
    end

    def create_object(row)
      object = @klass.new(attributes(row))
      begin
        create_fail(row) unless object.save
      rescue => e
        @errors <<
          "[#{@current_row}] Failed to create: #{row} - #{e.class}: #{e}"
      end
    end

    def attributes(row)
      row
        .to_hash
        .slice(*importable_attributes)
        .delete_if { |_, v| v == DO_NOT_IMPORT }
    end

    def update_fail(row)
      @errors << "[#{@current_row}] Failed to update: #{row}"
    end

    def create_fail(row)
      @errors << "[#{@current_row}] Failed to create: #{row}"
    end
  end
end
