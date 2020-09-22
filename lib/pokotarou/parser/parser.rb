require "pokotarou/additional_variables/main.rb"
require "pokotarou/additional_methods/main.rb"
require "pokotarou/additional_arguments/main.rb"
require "pokotarou/parser/parser_domain.rb"
require "pokotarou/p_tool.rb"


module Pokotarou
  class ParseError < StandardError; end
  FOREIGN_KEY_SYMBOL = "F|"
  COLUMN_SYMBOL = "C|"
  
  class ExpressionParser
    class << self
      
      def args; ::Pokotarou::AdditionalArguments::Main.args end
      def const; ::Pokotarou::AdditionalVariables::Main.const end
      
      def parse config_val, maked = nil, maked_col = nil
        begin
          case
          # Array
          when ParserDomain.is_array?(config_val)
            array_procees(config_val)
  
          # ForeignKey
          when ParserDomain.is_foreign_key?(config_val)
            foreign_key_process(config_val, maked_col)
  
          # Column
          when ParserDomain.is_column_symbol?(config_val)
            column_symbol_process(config_val, maked_col)
  
          # Expression
          when ParserDomain.is_expression?(config_val)
            expression_process(config_val, maked, maked_col)
  
          # Integer
          when ParserDomain.is_integer?(config_val)
            integer_process(config_val)
          
          # NeedUpdate
          when ParserDomain.is_need_update?(config_val)
            need_update_process(config_val, maked, maked_col)
  
          # Nil
          when ParserDomain.is_nil?(config_val)
            nil_process(config_val)
  
          # Other
          else
            nothing_apply_process(config_val)
          end
        rescue => e
          output_error(e)
        end
      end
  
      private
      def array_procees val
        return val
      end
  
      def foreign_key_process val, maked_col
        # remove 'F|'
        str_model = val.sub(FOREIGN_KEY_SYMBOL, "")
        model = eval(str_model)
        return model.pluck(:id)
      end
  
      def column_symbol_process val, maked_col
        # remove 'C|'
        str_model, column = val.sub(COLUMN_SYMBOL, "").split("|")
        model = eval(str_model)
        elemnts = model.pluck(column.to_sym)
        return elemnts.concat(maked_col[str_model.to_sym][column.to_sym])
      end
  
      def expression_process val, maked, maked_col
        # remove '<>'
        expression = val.strip[1..-2]
        ::Pokotarou::AdditionalMethods::Main.load
        return self.parse(eval(expression), maked, maked_col)
      end
  
      def integer_process val
        nothing_apply_process(val)
      end
  
      def need_update_process val, maked, maked_col
        return self.parse(val[:NeedUpdate], maked, maked_col)
      end
  
      def nil_process val
        nothing_apply_process(val)
      end
  
      def nothing_apply_process val
        # for escape \\
        val.instance_of?(String) ? val.tr("\\","") : val
      end
  
      def output_error e
        raise ParseError.new("Failed Expression parse:#{e.message}")
      end
    end
  end
end