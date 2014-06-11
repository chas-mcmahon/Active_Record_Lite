require_relative '03_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    unless self.class_name.downcase == "human"
      self.class_name.downcase.pluralize
    else
      self.class_name.downcase + 's'
    end
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    default = {
      :foreign_key => (name.to_s + "_id").to_sym,
      :class_name  => name.to_s.camelcase,
      :primary_key => :id
    }
    options = default.merge(options)

    @foreign_key = options[:foreign_key]
    @class_name  = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    default = {
      :foreign_key => (self_class_name.downcase.to_s + "_id").to_sym,
      :class_name => name.to_s.camelcase.singularize,
      :primary_key => :id
    }
    options = default.merge(options)

    @foreign_key = options[:foreign_key]
    @class_name  = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

module Associatable

  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      foreign_key_val = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => foreign_key_val).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      primary_key_val = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => primary_key_val)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
