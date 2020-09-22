module Pokotarou
  class AdditionalVariables
    module Main
      class << self
        CONST_KEY = :"const'"
        @const = {}
        attr_reader :const
  
        def set_const data
          return {} unless data.has_key?(CONST_KEY)
          @const = data[CONST_KEY]
  
          # parse expression configlation
          @const.each do |key, val|
            @const[key] = ConstParser.parse(val)
          end
  
          data.delete(CONST_KEY)
        end
  
        def remove
          @const = {}
        end
      
      end
    end  
  end
end