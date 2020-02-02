require "pokotarou/additional_methods.rb"
require "pokotarou/additional_variables/additional_variables.rb"
require "pokotarou/arguments/arguments.rb"
class ParseError < StandardError; end
FOREIGN_KEY_SYMBOL = "F|"

class ExpressionParser
  class << self
    def parse config_val, maked = nil, maked_col = nil
      begin
        case
        # Array
        when is_array?(config_val)
          array_procees(config_val)

        # ForeignKey
        when is_foreign_key?(config_val)
          foreign_key_process(config_val, maked_col)

        # Expression
        when is_expression?(config_val)
          expression_process(config_val, maked, maked_col)

        # Integer
        when is_integer?(config_val)
          integer_process(config_val)

        # Nil
        when is_nil?(config_val)
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
      ids = model.pluck(:id)
      return ids.concat(maked_col[str_model.to_sym][:id])
    end

    def expression_process val, maked, maked_col
      # remove '<>'
      expression = val.strip[1..-2]
      require AdditionalVariables.filepath if AdditionalVariables.const.present?
      require AdditionalMethods.filepath if AdditionalMethods.filepath.present?
      require Arguments.filepath if Arguments.filepath.present?
      return self.parse(eval(expression), maked, maked_col)
    end

    def integer_process val
      nothing_apply_process(val)
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

# for seed data
class SeedExpressionParser < ExpressionParser
  class << self
    private
    def nothing_apply_process val
      # for escape \\
      val.instance_of?(String) ? [val.tr("\\","")] : [val]
    end

    def output_error e
      raise ParseError.new("Failed Seed Expression parse:#{e.message}")
    end
  end
end

# for return variables
class ReturnExpressionParser < ExpressionParser
  class << self
    private
    def output_error e
      ParseError.new("Failed Const Expression parse:#{e.message}")
    end
  end
end

# for loop data
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
      ids = model.pluck(:id)
      return ids.concat(maked_col[str_model.to_sym][:id]).size
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

# for const variables
class ConstExpressionParser < ExpressionParser
  class << self
    private
    def expression_process val, _, _
      # remove '<>'
      expression = val.strip[1..-2]
      require AdditionalMethods.filepath if AdditionalMethods.filepath.present?
      require Arguments.filepath if Arguments.filepath.present?
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

FOREIGN_KEY = /^F\|[A-Z][:A-Za-z0-9]*$/
def is_foreign_key? val
  return false unless val.kind_of?(String)
  FOREIGN_KEY =~ val
end

EXPRESSION = /^\s*<.*>\s*$/
def is_expression? val
  return false unless val.kind_of?(String)
  EXPRESSION =~ val
end

def is_array? val
  val.instance_of?(Array)
end

def is_integer? val
  val.instance_of?(Integer)
end

def is_nil? val
  val.nil?
end