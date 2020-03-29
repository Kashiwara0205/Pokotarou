module AdditionalVariables
  class << self
    CONST_KEY = :"const'"
    @const = {}
    attr_reader :const

    LET_KEY = :let
    @let = {}
    attr_reader :let
    
    def set_const data
      set_const_variables(data)
    end

    def set_let data
      set_let_variables(data)
    end

    def remove
      @const = {}
      @let = {}
    end

    def remove_let
      @let = {}
    end

    def filepath
      "pokotarou/additional_variables/def_variable.rb"
    end

    private 

    def set_let_variables data
      return {} unless data.has_key?(LET_KEY)
      @let = data[LET_KEY]

      @let.each do |key, val|
        @let[key] = { IDENT: val }
      end

      data.delete(LET_KEY)
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