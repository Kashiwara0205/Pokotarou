Dir[File.expand_path('../pokotarou', __FILE__) << '/*.rb'].each do |file|
  require file
end
require "activerecord-import"

module Pokotarou
  class NotFoundLoader < StandardError; end

  class << self
    def execute filepath
      do_seed(get_config(filepath))
    end

    def import filepath
      AdditionalMethods.import(filepath)
    end

    def reset
      AdditionalMethods.remove()
    end

    def get_config filepath
      contents = load_file(filepath)
      DataStructure.gen(contents)
    end

    def do_seed data
      DataRegister.regist(data)
    end

    private

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
