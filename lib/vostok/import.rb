require 'pg'

module Vostok
  class Import
    attr_reader :connection, :pg_connection, :table

    def initialize(connection)
      @connection = connection
      @options = {batch_size: 1000}
    end

    def start(table, columns, values, options = @options)
      validate_args(columns, values)
      @table = table
      begin
        @pg_connection = PG::Connection.open(@connection)
        values.each_slice(options[:batch_size]) do |slice|
          sql = generate_sql(table, columns, slice)
          @pg_connection.exec(sql)
        end
        values.length
      ensure
        @pg_connection.close
      end
    end

    private

    def validate_args(columns, values)
      raise ArgumentError, 'Columns names must be a non-empty array' if columns.nil? || columns.empty?
      raise ArgumentError, 'Column names must correspond to values' if values.length > 0 && values[0].length != columns.length
    end

    def generate_sql(table, columns, values_slice)
      columns_sql = columns.join('","')
      values_sql = values_slice.map{|i| "('" + i.join("','") + "')"}.join(',')
      "insert into \"#{table.to_s}\" (\"#{columns_sql}\") values#{values_sql}"
    end
  end
end