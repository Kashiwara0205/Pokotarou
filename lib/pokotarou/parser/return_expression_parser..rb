require "pokotarou/parser/parser.rb"

# for return variables
module Pokotarou
  class ReturnExpressionParser < ExpressionParser
    class << self
      private
      def output_error e
        ParseError.new("Failed Const Expression parse:#{e.message}")
      end

      def foreign_key_process val, _
        # remove 'F|'
        str_model = val.sub(FOREIGN_KEY_SYMBOL, "")
        model = eval(str_model)
        return model.pluck(:id)
      end

      def column_symbol_process val, _
        # remove 'C|'
        str_model, column = val.sub(COLUMN_SYMBOL, "").split("|")
        model = eval(str_model)
        return model.pluck(column.to_sym)
      end
    end
  end
end