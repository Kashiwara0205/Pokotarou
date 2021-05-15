require "pokotarou/parser/parser.rb"

# for seed data
module Pokotarou
  class SeedExpressionParser < ExpressionParser
    class << self
      private
      def nothing_apply_process val
        # for escape \\
        val.instance_of?(String) ? [val.tr("\\","")] : [val]
      end

      def output_error e
        raise ParseError.new("Failed parse [  #{e.message} ]")
      end
    end 
  end
end
