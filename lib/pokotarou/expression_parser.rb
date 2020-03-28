require "pokotarou/additional_methods.rb"
require "pokotarou/additional_variables/additional_variables.rb"
require "pokotarou/arguments/arguments.rb"
class ParseError < StandardError; end
FOREIGN_KEY_SYMBOL = "F|"
COLUMN_SYMBOL = "C|"

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

        # Column
        when is_column_symbol?(config_val)
          column_symbol_process(config_val, maked_col)

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
      require AdditionalVariables.filepath if AdditionalVariables.const.present?
      AdditionalMethods.filepathes.each do |filepath|; require filepath end
      AdditionalMethods.filepathes_from_yml.each do |filepath|; require filepath end
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

# for const variables
class ConstExpressionParser < ExpressionParser
  class << self
    private
    def expression_process val, _, _
      # remove '<>'
      expression = val.strip[1..-2]
      AdditionalMethods.filepathes.each do |filepath|; require filepath end
      AdditionalMethods.filepathes_from_yml.each do |filepath|; require filepath end
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

def is_nil? val
  val.nil?
end