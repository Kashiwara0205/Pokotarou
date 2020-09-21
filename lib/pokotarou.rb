Dir[File.expand_path('../pokotarou', __FILE__) << '/*.rb'].each do |file|
  require file
end

require "activerecord-import"
require "pokotarou/registration_config_maker/main.rb"
require "pokotarou/seed_data_register/main.rb"

module Pokotarou
  class Operater
    class NotFoundLoader < StandardError; end
    class << self
      def execute input
        init_proc()
  
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
        init_proc()
  
        return_vals = []
        input_arr.each do |e|
          handler = gen_handler_with_cache(e[:filepath])
  
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
        init_proc()
  
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
  
      def gen_handler filepath
        init_proc()
  
        PokotarouHandler.new(gen_config(filepath))
      end
  
      def gen_handler_with_cache filepath
        init_proc()
  
        @handler_cache ||= {}
        @handler_cache[filepath] ||= PokotarouHandler.new(gen_config(filepath))
  
        @handler_cache[filepath].deep_dup
      end
  
      private
      def init_proc
        AdditionalMethods::Main.init()
      end
  
      def gen_config filepath
        contents = load_file(filepath)
        AdditionalVariables::Main.set_const(contents)
        RegistrationConfigMaker::Main.gen(contents)
      end
  
      def load_file filepath
        case File.extname(filepath)
        when ".yml"
          return YAML.load_file(filepath).deep_symbolize_keys!
        else
          raise NotFoundLoader.new("not found loader")
        end
      end
    end
  end
end

module Pokotarou
  class << self
    def execute input
      Operater.execute(input)
    end

    def pipeline_execute input_arr
      Operater.pipeline_execute(input_arr)
    end

    def import filepath
      Operater.import(filepath)
    end

    def set_args hash
      Operater.set_args(hash)
    end

    def reset
      Operater.reset()
    end

    def gen_handler filepath
      Operater.gen_handler(filepath)
    end

    def gen_handler_with_cache filepath
      Operater.gen_handler_with_cache(filepath)
    end
  end
end

class PokotarouHandler
  def initialize data
    @data = data
  end

  def make
    ::Pokotarou::Operater.execute(get_data())
  end

  def delete_block sym_block
    @data.delete(sym_block)
  end

  def delete_model sym_block, sym_class
    @data[sym_block].delete(sym_class)
  end

  def delete_col sym_block, sym_class, sym_col
    exists_content = ->(key){ @data[sym_block][sym_class][key].present? }

    @data[sym_block][sym_class][:col].delete(sym_col) if exists_content.call(:col)
    @data[sym_block][sym_class][:option].delete(sym_col) if exists_content.call(:option)
    @data[sym_block][sym_class][:convert].delete(sym_col) if exists_content.call(:convert)
  end

  def change_loop sym_block, sym_class, n
    @data[sym_block][sym_class][:loop] = n
  end

  def change_seed sym_block, sym_class, sym_col, arr
    @data[sym_block][sym_class][:col][sym_col] = arr
  end

  def get_data
    @data.deep_dup
  end

  def set_data data
    @data = data
  end
 
  def set_randomincrement sym_block, sym_class, status
    @data[sym_block][sym_class][:randomincrement] = status
  end

  def set_autoincrement sym_block, sym_class, status
    @data[sym_block][sym_class][:autoincrement] = status
  end
end