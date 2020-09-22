module Pokotarou
  module RegistrationConfigMaker
    class ColumnDomain
      class << self
        def is_foreign_key? col_name_sym, foreign_key_dict
          return foreign_key_dict[col_name_sym].present?
        end
  
        ENUM_REGEX = /^enum(\s*.)*$/
        def is_enum? sql_type
          return false unless sql_type.kind_of?(String)
          return ENUM_REGEX =~ sql_type
        end
      end
    end
  end
end