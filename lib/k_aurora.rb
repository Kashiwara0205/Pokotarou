Dir[File.expand_path('../k_aurora', __FILE__) << '/*.rb'].each do |file|
  require file
end
require "activerecord-import"

module KAurora
  class NotFoundLoader < StandardError; end

  class << self
    def execute filepath
      contents = load_file(filepath)
      data = DataStructure.gen(contents)
      DataRegister.regist(data)
    end

    def import filepath
      AdditionalMethods.import(filepath)
    end

    def reset
      AdditionalMethods.remove()
    end

    def get_data filepath
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
