require "pokotarou/parser/parser.rb"

# for loop data
module Pokotarou
  class LoopExpressionParser < ExpressionParser
    class << self
      private
      def array_procees val
        val.size
      end

      def foreign_key_process val, maked_col
        # remove 'F|'
        str_model = val.sub(FOREIGN_KEY_SYMBOL, "")
        model = eval(str_model)
        return model.pluck(:id).size
      end

      def integer_process val
        val
      end

      def nil_process _
        1
      end

      def output_error e
        ParseError.new("Failed Loop Expression parse: #{e.message}")
      end
    end 
  end
end