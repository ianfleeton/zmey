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

    if object = @klass.find_by(id: row['id'])
      if !object.update_attributes(attributes)
        @errors << "[#{@current_row}] Failed to updated: #{row}"
      end
    else
      object = @klass.new(attributes)
      begin
        unless object.save
          @errors << "[#{@current_row}] Failed to create: #{row}"
        end
      rescue Exception => e
        @errors << "[#{@current_row}] Failed to create: #{row} - #{e.class}: #{e}"
      end
    end
    object.after_import if object.respond_to?(:after_import)
  end

  def importable_attributes
    @attrs ||= @klass.respond_to?(:importable_attributes) ? @klass.importable_attributes : @klass.attribute_names
  end

  private

    def reset
      @current_row = 1
      @errors = []
    end
end
