module Pokotarou
  class ParserDomain
    class << self
      FOREIGN_KEY_REGEXP = /^F\|[A-Z][:A-Za-z0-9]*$/
      def is_foreign_key? val
        return false unless val.kind_of?(String)
        FOREIGN_KEY_REGEXP =~ val
      end
      
      COLUMN_REGEXP  = /^C\|[A-Z][:A-Za-z0-9]*\|[a-z][:a-z0-9]*$/
      def is_column_symbol? val
        return false unless val.kind_of?(String)
        COLUMN_REGEXP =~ val
      end
      
      EXPRESSION_REGEXP = /^\s*<.*>\s*$/
      def is_expression? val
        return false unless val.kind_of?(String)
        EXPRESSION_REGEXP =~ val
      end
      
      def is_array? val
        val.instance_of?(Array)
      end
      
      def is_integer? val
        val.instance_of?(Integer)
      end
      
      def is_need_update? val
        return false unless val.kind_of?(Hash)
        val.has_key?(:NeedUpdate)
      end
      
      def is_nil? val
        val.nil?
      end 
    end
  end
end