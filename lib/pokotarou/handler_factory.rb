require "pokotarou/handler"
require "pokotarou/registration_config_maker/main"

module Pokotarou

  class HandlerFactory
    class << self
      def gen_handler filepath
        AdditionalMethods::Main.init()
  
        Handler.new(gen_config(filepath))
      end
  
      def gen_handler_with_cache filepath
        AdditionalMethods::Main.init()
  
        @handler_cache ||= {}
        @handler_cache[filepath] ||= Handler.new(gen_config(filepath))
  
        @handler_cache[filepath].deep_dup
      end

      private
      def gen_config filepath
        RegistrationConfigMaker::Main.gen(filepath)
      end
    end
  end
end