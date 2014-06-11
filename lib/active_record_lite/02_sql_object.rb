require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    new_results = results.map do |result|
      self.new(result)
    end
    new_results
  end

  def self.my_attr_accessor(columns)
    columns.each do |col|
      define_method(col) { self.attributes[col] }
      define_method("#{col}=") { |new_val| self.attributes[col] = new_val }
    end
  end
end

class SQLObject < MassObject

  def self.columns
    unless @cols
    cols = DBConnection.execute2("SELECT * FROM #{table_name}")
    @cols = cols[0].map { |col| col.to_sym }
    self.my_attr_accessor(@cols)
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
  end

  def self.find(id)
    entry = DBConnection.execute(<<-SQL, id)
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
    col_names = self.attributes.keys.join(", ")
    question_marks = (["?"] * self.attributes.length).join(", ")

    DBConnection.execute(<<-SQL, *self.attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VAlUES
      (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    columns = self.class.columns

    params.each do |attr_name, val|
      unless columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      else
        self.send("#{attr_name}=", val)
      end
    end
  end

  def save
    self.id.nil? ? self.insert : self.update
  end

  def update
    set_line = (self.class.columns.map { |col| "#{col} = ?"}).join(", ")

    DBConnection.execute(<<-SQL, *self.attribute_values, self.id)
    UPDATE
    #{self.class.table_name}
    SET
    #{set_line}
    WHERE
    id = ?
    SQL
  end

  def attribute_values
    self.attributes.values
  end
end
