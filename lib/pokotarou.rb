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
        DataRegister.regist(gen_config(input))
      else
        DataRegister.regist(input)
      end
    end

    def import filepath
      AdditionalMethods.import(filepath)
    end

    def reset
      AdditionalMethods.remove()
    end

    def gen_handler filepath
      PokotarouHandler.new(gen_config(filepath))
    end

    private

    def gen_config filepath
      contents = load_file(filepath)
      DataStructure.gen(contents)
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
