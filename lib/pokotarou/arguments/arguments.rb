class MisMatchArgType < StandardError; end
module Arguments
  class << self
    @args = nil
    attr_reader :args
    
    def import hash_data
      unless hash_data.kind_of?(Hash)
        raise MisMatchArgType.new("Please use Hash for args")
      end

      @args = hash_data
    end

    def remove
      @args = nil
    end

    def filepath
      "pokotarou/arguments/def_args.rb"
    end

  end  
end