require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable

  def where(params)
    where_line = (params.map { |k,v| "#{k} = ?"}).join(" AND ")
    tuples = DBConnection.execute(<<-SQL, params.values)
    SELECT
    *
    FROM
    #{self.table_name}
    WHERE
    #{where_line}
    SQL
    parse_all(tuples)
  end
end

class SQLObject
  extend Searchable
end
