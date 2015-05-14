class CSVExporter
  def initialize(class_name)
    @klass = Kernel.const_get(class_name)
    @object = @klass.new
  end

  def generate
    CSV.generate do |csv|
      row_arr = []
      attribute_names.each do |attribute|
        row_arr << attribute
      end
      csv << row_arr

      records.each do |record|
        row_arr = []
        attribute_names.each do |attribute|
          row_arr << record.send(attribute)
        end
        csv << row_arr
      end
    end
  end

  def attribute_names
    @attribute_names ||= @klass.respond_to?(:exportable_attributes) ? @klass.exportable_attributes : @klass.attribute_names
  end

  def filename
    time.strftime("%Y%m%d-%H%M") + "-#{@klass}.csv"
  end

  def time
    Time.zone.now
  end

  def records
    if @klass.respond_to?(:export)
      # Allow a model class to determine which records to export
      @klass.export
    else
      # Limit records to prevent memory problems.
      @klass.order(created_at: :desc).limit(record_limit)
    end
  end

  def record_limit
    10_000
  end
end
