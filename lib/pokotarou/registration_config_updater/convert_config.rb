module Pokotarou
  module RegistrationConfigUpdater
    class ConvertConfig 
      class << self
        PARENTHESES = /\(.*\)/
        def execute arr, config
          return arr if config.nil?
          config.each do |e|
            range = eval(e.slice(PARENTHESES).delete("()"))
            convert_name = e.gsub(PARENTHESES, "")
            arr[range] = get_val(convert_name, range.size)
          end
    
          arr
        end
  
        private
        def get_val convert_name, size
          return [""] * size if convert_name == "empty"
          return [nil] * size if convert_name == "nil"
          return ["text\n" * 5] * size if convert_name == "br_text"
          return ["text" * 50] * size if convert_name == "big_text"
        end
    
      end
    end
  end
end