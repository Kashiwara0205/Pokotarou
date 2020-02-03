Dir[File.expand_path('../pokotarou', __FILE__) << '/*.rb'].each do |file|
  require file
end

require "activerecord-import"

module Pokotarou
  class NotFoundLoader < StandardError; end

  class << self
    def execute input
      # if input is filepath, generate config_data
      if input.kind_of?(String)
        DataRegister.register(gen_config(input))
      else
        DataRegister.register(input)
      end
    end

    def pipleine_execute input_arr
      return_vals = []
      input_arr.each do |e|
        handler = gen_handler_with_cache(e[:filepath])

        if e[:change_data].present?
          e[:change_data].each do |block, config|
            config.each do |model, seed|
              seed.each do |col_name, val|         
                handler.change_seed(block, model, col_name, val)
              end
            end
          end
        end
        
        e[:args] ||= {}
        e[:args][:passed_return_val] = return_vals.last
        set_args(e[:args])

        return_vals << Pokotarou.execute(handler.get_data())
      end

      return_vals
    end

    def import filepath
      AdditionalMethods.import(filepath)
    end

    def set_args hash
      Arguments.import(hash)
    end

    def reset
      AdditionalMethods.remove()
      Arguments.remove()
      @handler_chache = {}
    end

    def gen_handler filepath
      PokotarouHandler.new(gen_config(filepath))
    end

    def gen_handler_with_cache filepath
      @handler_cache ||= {}
      @handler_cache[filepath] ||= PokotarouHandler.new(gen_config(filepath))

      @handler_cache[filepath].deep_dup
    end

    private

    def gen_config filepath
      contents = load_file(filepath)
      set_const_val_config(contents)
      DataStructure.gen(contents)
    end

    def set_const_val_config contents
      AdditionalVariables.import(contents)
    end

    def load_file filepath
      case File.extname(filepath)
      when ".yml"
        return YmlLoader.load(filepath)
      else
        raise NotFoundLoader.new("not found loader")
      end
    end

  end
end
