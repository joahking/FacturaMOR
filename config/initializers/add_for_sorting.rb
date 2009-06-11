module FacturaGem
  module Sorting
    # This class method generates methods like this one:
    #
    # def first_name=(fname)
    #    write_attribute(:first_name, fname)
    #    write_attribute(:first_name_for_sorting, FacturagemUtils.normalize_for_sorting(fname))
    #  end
    def add_for_sorting_to(*fields)
      fields.each do |f|
        class_eval <<-EOS
          def #{f}=(v)
            write_attribute(:#{f}, v)
            write_attribute(:#{f}_for_sorting, FacturagemUtils.normalize_for_sorting(v))
          end
        EOS
      end
    end
  end
end

ActiveRecord::Base.extend FacturaGem::Sorting
