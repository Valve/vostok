require 'pg'

module Vostok
  class Import
    attr_reader :pg_connection, :table
    @connection_external = false

    def initialize(connection)
      raise ArgumentError, 'Connection can not be null' unless connection
      raise ArgumentError, 'Connection must be a Hash or a PG::Connection' unless (connection.is_a?(::Hash) || connection.is_a?(PG::Connection))
      if connection.is_a? ::Hash
        @pg_connection = PG::Connection.new(connection)
      else
        @pg_connection = connection
        @connection_external = true
      end
      @options = {batch_size: 1000}
    end

    def start(table, columns, values, options = @options)
      validate_args(columns, values)
      @table = table
      begin
        values.each_slice(options[:batch_size]) do |slice|
          sql = generate_sql(table, columns, slice)
          @pg_connection.exec(sql)
        end
        values.length
      ensure
        @pg_connection.close unless @connection_external
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