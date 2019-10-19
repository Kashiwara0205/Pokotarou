require "pokotarou/additional_methods.rb"
require "pokotarou/additional_variables/additional_variables.rb"
class ParseError < StandardError; end
FOREIGN_KEY_SYMBOL = "F|"

# for seed data
class ExpressionParser
  class << self
    def parse config_val, maked
      begin
        case
        when config_val.instance_of?(Array)
          return config_val
        when is_foreign_key?(config_val)
          # remove 'F|'
          str_model = config_val.sub(FOREIGN_KEY_SYMBOL, "")
          model = eval(str_model)
          return model.pluck(:id)
        when is_expression?(config_val)
          # remove '<>'
          expression = config_val.strip[1..-2]
          require AdditionalVariables.filepath if AdditionalVariables.const.present?
          require AdditionalMethods.filepath if AdditionalMethods.filepath.present?
          return self.parse(eval(expression), maked)
        else
          if config_val.instance_of?(String)
            # escape \\
            [config_val.tr("\\","")]
          else
            [config_val]
          end
        end
      rescue => e
        ParseError.new("Failed Expression parse:#{e.message}")
      end
    end
  end
end

# for loop data
class LoopExpressionParser
  class << self
    def parse config_val, maked
      begin
        case
        when config_val.instance_of?(Array)
          return config_val.size
        when config_val.instance_of?(Integer)
          return config_val
        when config_val.nil?
          return 1
        when is_foreign_key?(config_val)
          # remove 'F|'
          str_model = config_val.sub(FOREIGN_KEY_SYMBOL, "")
          model = eval(str_model)
          return model.pluck(:id).size
        when is_expression?(config_val)
          # remove '<>'
          expression = config_val.strip[1..-2]
          require AdditionalVariables.filepath if AdditionalVariables.const.present?
          require AdditionalMethods.filepath if AdditionalMethods.filepath.present?
          return self.parse(eval(expression), maked)
        else
          return 1
        end
      rescue => e
        ParseError.new("Failed Loop Expression parse: #{e.message}")
      end
    end
  end
end

# for const variables
class ConstExpressionParser
  class << self
    def parse config_val
      begin
        case
        when config_val.instance_of?(Array)
          return config_val
        when is_foreign_key?(config_val)
          # remove 'F|'
          str_model = config_val.sub(FOREIGN_KEY_SYMBOL, "")
          model = eval(str_model)
          return model.pluck(:id)
        when is_expression?(config_val)
          # remove '<>'
          expression = config_val.strip[1..-2]
          require AdditionalMethods.filepath if AdditionalMethods.filepath.present?
          return self.parse(eval(expression))
        else
          if config_val.instance_of?(String)
            # escape \\
            config_val.tr("\\","")
          else
            config_val
          end
        end
      rescue => e
        ParseError.new("Failed Const Expression parse:#{e.message}")
      end
    end
  end
end

# for return variables
class ReturnExpressionParser
  class << self
    def parse config_val, maked
      begin
        case
        when config_val.instance_of?(Array)
          return config_val
        when is_foreign_key?(config_val)
          # remove 'F|'
          str_model = config_val.sub(FOREIGN_KEY_SYMBOL, "")
          model = eval(str_model)
          return model.pluck(:id)
        when is_expression?(config_val)
          # remove '<>'
          expression = config_val.strip[1..-2]
          require AdditionalVariables.filepath if AdditionalVariables.const.present?
          require AdditionalMethods.filepath if AdditionalMethods.filepath.present?
          return self.parse(eval(expression), maked)
        else
          if config_val.instance_of?(String)
            # escape \\
            config_val.tr("\\","")
          else
            config_val
          end
        end
      rescue => e
        ParseError.new("Failed Const Expression parse:#{e.message}")
      end
    end
  end
end

FOREIGN_KEY = /^F\|[A-Z][:A-Za-z0-9]*$/
def is_foreign_key? val;
  return false unless val.kind_of?(String)
  FOREIGN_KEY =~ val
end

EXPRESSION = /^\s*<.*>\s*$/
def is_expression? val
  return false unless val.kind_of?(String)
  EXPRESSION =~ val
end