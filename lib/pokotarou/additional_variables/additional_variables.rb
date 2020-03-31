module AdditionalVariables
  class << self
    CONST_KEY = :"const'"
    @const = {}
    attr_reader :const

    def set_const data
      set_const_variables(data)
    end

    def remove
      @const = {}
    end

    def filepath
      "pokotarou/additional_variables/def_variable.rb"
    end

    private 
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