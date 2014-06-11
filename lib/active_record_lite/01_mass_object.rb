require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject

  def self.attributes
    if self == MassObject
      raise "must not call #attributes on MassObject directly"
    else
      @attributes ||= []
    end
  end

  def initialize(params = {})
    params.each do |k, v|
      self.send("#{k}=", v)
    end
  end

end
