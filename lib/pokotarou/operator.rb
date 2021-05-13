require "pokotarou/handler_factory"
require "pokotarou/registration_config_maker/main"
require "pokotarou/additional_arguments/main"
require "pokotarou/additional_methods/main"
require "pokotarou/additional_variables/main"
require "pokotarou/seed_data_register/main.rb"
require "pokotarou/parser/const_parser.rb"

module Pokotarou
  class Operator
    class NotFoundLoader < StandardError; end
    class << self
      def execute input
        AdditionalMethods::Main.init()
  
        # if input is filepath, generate config_data
        return_val =
          if input.kind_of?(String)
            SeedDataRegister::Main.register(gen_config(input))
          else
            SeedDataRegister::Main.register(input)
          end
  
        AdditionalMethods::Main.remove_filepathes_from_yml()
  
        return_val
      end
  
      def pipeline_execute input_arr
        AdditionalMethods::Main.init()
  
        return_vals = []
        input_arr.each do |e|
          handler = HandlerFactory.gen_handler_with_cache(e[:filepath])
  
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
          AdditionalMethods::Main.remove_filepathes_from_yml()
        end
  
        return_vals
      end
  
      def import filepath
        AdditionalMethods::Main.init()
        AdditionalMethods::Main.import(filepath)
      end
  
      def set_args hash
        AdditionalArguments::Main.import(hash)
      end
  
      def reset
        AdditionalMethods::Main.remove()
        AdditionalArguments::Main.remove()
        AdditionalVariables::Main.remove()
        @handler_chache = {}
      end
  
      def gen_config filepath
        RegistrationConfigMaker::Main.gen(filepath)
      end
      
    end
  end
end