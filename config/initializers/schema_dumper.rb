# Dump each table's columns to db/schema.rb in alphabetical order (after the
# primary key) rather than in database column order.
#
# A database built by running migrations and one loaded from schema.rb have
# their columns in different physical orders. Sorting makes both dump to the
# same file, so migrations only touch the lines they change.
#
# Rails 8.1.0 did this itself, but it was reverted because databases created by
# db:prepare get their columns in a different order from migrated ones. That
# doesn't matter here: code never relies on the physical order of columns.
module SortedSchemaColumns
  class Connection < SimpleDelegator
    def columns(table_name)
      __getobj__.columns(table_name).sort_by(&:name)
    end
  end

  def table(table, stream)
    connection = @connection
    @connection = Connection.new(connection)
    super
  ensure
    @connection = connection
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::SchemaDumper.prepend(SortedSchemaColumns)
end
