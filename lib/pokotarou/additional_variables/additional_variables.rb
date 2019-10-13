module AdditionalVariables
  class << self
    CONST_KEY = :"const'"
    @const = nil
    attr_reader :const
    
    def import data
      return unless data.has_key?(CONST_KEY)
      @const = data[CONST_KEY]
      data.delete(CONST_KEY)
    end

    def filepath
      "pokotarou/additional_variables/def_const.rb"
    end

  end  
end