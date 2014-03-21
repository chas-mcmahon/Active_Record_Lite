require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
    results
  end

  #sets up getters/setters for each column
  def my_attr_accessor(columns)
    columns.each do |col|
      define_method(col) { self.attributes[col] }
      define_method("#{col}=") { |new_val| self.attributes[col] = new_val }
    end
  end
end

class SQLObject < MassObject

  def self.columns
    unless @cols
    cols = DBConnection.execute2("SELECT * FROM #{table_name}")#check this
    @cols = cols[0].map { |col| col.to_sym }
    self.my_attr_accessor(*@cols)
    end
    @cols
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    unless @table_name
      @table_name = self.to_s.underscore.pluralize.downcase
    end
    @table_name
  end

  def self.all
    tuple_array = DBConnection.execute("SELECT #{table_name}.* FROM #{table_name}")
    parse_all(tuple_array)

    # tuple_array.each do |tuple|
#       self.parse_all(tuple)
#     end
#     tuple_array

    # query = <<-SQL
#     SELECT
#     #{self.table_name}.*
#     FROM
#     #{self.table_name}
#     SQL
#
#     tuple_array = DBConnection.execute(query)
  end

  def self.find(id)
    entry = DBConnection.execute(<<-SQL, id)#wrong way to interpolate the id
    SELECT
    #{self.table_name}.*
    FROM
    #{self.table_name}
    WHERE
    #{self.table_name}.id = ?
    SQL
    parse_all(entry)[0]
  end

  def attributes
    if @attributes.nil?
      @attributes = Hash.new{0}
    else
      @attributes
    end
  end

  def insert
    # ...
  end

  def initialize(params = {})
    columns = self.class.columns

    params.each do |attr_name, val|
      attr_name.to_sym
      unless columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      else
        self.send("#{attr_name}=", val)
      end
    end
  end

  def save
    # ...
  end

  def update
    # ...
  end

  def attribute_values
    # ...
  end
end
