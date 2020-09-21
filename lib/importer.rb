class Importer
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
    attributes = row.to_hash.slice(*importable_attributes)

    if (object = find_object(row))
      unless object.update(attributes)
        @errors << "[#{@current_row}] Failed to updated: #{row}"
      end
    else
      object = @klass.new(attributes)
      begin
        unless object.save
          @errors << "[#{@current_row}] Failed to create: #{row}"
        end
      rescue => e
        @errors << "[#{@current_row}] Failed to create: #{row} - #{e.class}: #{e}"
      end
    end
    object.after_import if object.respond_to?(:after_import)
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
end
