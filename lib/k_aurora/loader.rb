class FileLoader
  class << self
    # load data with the use of indicated filepath 
    def load filepath
    end
  end
end

class YmlLoader < FileLoader
  class << self
    def load filepath
      # convert 'str_key' to 'symbol_key'
      YAML.load_file(filepath).deep_symbolize_keys!
    end
  end
end