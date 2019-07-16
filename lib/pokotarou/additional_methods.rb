module AdditionalMethods
  class << self
    @filepath = nil
    attr_reader :filepath

    def import filepath
      @filepath = filepath
    end

    def remove
      @filepath = nil
    end
  end
end