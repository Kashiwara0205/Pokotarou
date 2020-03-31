module AdditionalMethods
  class << self
    attr_reader :filepathes
    attr_reader :filepathes_from_yml

    @filepathes = []
    @filepathes_from_yml = []

    def init
      @filepathes ||= []
      @filepathes_from_yml = []
    end

    def import filepath
      add(@filepathes, filepath)
    end

    def import_from_yml filepath
      add(@filepathes_from_yml, filepath)
    end

    def remove
      @filepathes = []
      @filepathes_from_yml = []
    end

    def remove_filepathes_from_yml
      @filepathes_from_yml = []
    end

    private
    def add filepath_arr, filepath
      if filepath.instance_of?(Array)
        filepath_arr.concat(filepath)
      else
        filepath_arr.push(filepath)
      end
    end
  end
end