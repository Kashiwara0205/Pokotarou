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

    def batch_execute input_arr
      handlers = {}
      input_arr.each do |e|
        handlers[e[:file_path]] ||= Pokotarou.gen_handler(e[:file_path])
      end

      BatchDataRegister.register(input_arr, handlers)
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

    def gen_handler filepath, cahce = true
      if cahce
        @handler_chache ||= {}
        @handler_chache[filepath] ||= PokotarouHandler.new(gen_config(filepath))
        @handler_chache[filepath].deep_dup()
      else
        PokotarouHandler.new(gen_config(filepath))
      end
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
