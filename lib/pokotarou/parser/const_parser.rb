require "pokotarou/parser/parser.rb"

# for const variables
module Pokotarou
  class ConstParser < ExpressionParser
    class << self
      private
      def expression_process val, _, _
        # remove '<>'
        expression = val.strip[1..-2]
        ::Pokotarou::AdditionalMethods::Main.load
        return self.parse(eval(expression))
      end
  
      def nothing_apply_process val
        # for escape \\
        val.instance_of?(String) ? val.tr("\\","") : val
      end
  
      def output_error
        ParseError.new("Failed Const Expression parse: #{e.message}")
      end
    end
  end
end