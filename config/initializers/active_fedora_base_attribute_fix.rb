require 'nest'

ActiveFedora::Base.class_eval do

  def self.create_attribute_reader(field, dsid, args)
    find_or_create_defined_attribute(field, dsid, args)

    define_method field do |*opts|
      val = Array(array_reader(field, *opts))
      self.class.multiple?(field) ? val : val.first
    end
  end

end
