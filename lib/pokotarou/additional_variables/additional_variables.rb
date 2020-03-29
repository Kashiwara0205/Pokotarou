module AdditionalVariables
  class << self
    CONST_KEY = :"const'"
    @const = {}
    attr_reader :const

    LET_KEY = :let
    @let = {}
    @first_let = {}
    attr_reader :let
    attr_reader :first_let
    
    def set_const data
      set_const_variables(data)
    end

    def set_let data
      set_let_variables(data)
    end

    def remove
      @const = {}
      @let = {}
      @first_let = {}
    end

    def init_let
      @let = {}
      @first_let = {}
    end

    def filepath
      "pokotarou/additional_variables/def_variable.rb"
    end

    private 

    def set_let_variables data
      return {} unless data.has_key?(LET_KEY)
      @let = data[LET_KEY]

      @let.each do |key, val|
        if is_expression?(val)
          @let[key] = { NeedUpdate: val }
        else
          @let[key] = val
        end
      end

      data.delete(LET_KEY)

      @first_let = @let.deep_dup
    end

    EXPRESSION_REGEXP = /^\s*<.*>\s*$/
    def is_expression? val
      return false unless val.kind_of?(String)
      EXPRESSION_REGEXP =~ val
    end

    def set_const_variables data
      return {} unless data.has_key?(CONST_KEY)
      @const = data[CONST_KEY]

      # parse expression configlation
      @const.each do |key, val|
        @const[key] = ConstParser.parse(val)
      end

      data.delete(CONST_KEY)
    end

  end  
end