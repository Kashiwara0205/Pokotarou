require "pokotarou/additional_variables/additional_variables.rb"
require "pokotarou/registration_config_updater/main.rb"

module SeedDataRegister
  class Main
    class RegisterError < StandardError; end
    class SeedError < StandardError; end

    class << self
      def register data
        # init maked to accumulate maded data
        maked = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
        maked_col = Hash.new { |h,k| h[k] = {} }
        # init model_data to cache data of model
        model_cache = {}
        ActiveRecord::Base.transaction do
          begin
            data.each do |sym_block, model_data|
              next if is_dush?(sym_block.to_s)
              register_val_by_bulk(sym_block, model_data, maked, model_cache, maked_col)
            end
          rescue => e
            raise StandardError.new("#{e.message}")
          end
        end
    
        ReturnExpressionParser.parse(data[:"return'"], maked, maked_col)
      end
    
      private
    
      def register_val_by_bulk block_name_sym, model_data, maked, model_cache, maked_col
        model_data.each do |e|
          begin
            t = Time.now
            ::RegistrationConfigUpdater::Main.update(e, block_name_sym, model_cache, maked, maked_col)
    
            model_name = e.first.to_s
            model_config = e.second
            output_log(model_config[:log])
            insert_record(block_name_sym, model_name, model_config ,model_cache)

          rescue => e
            print "\e[31m"
            puts "[Pokotarou ERROR]"
            puts "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
            puts "Failed Register record"
            puts "BLOCK: #{block_name_sym}"
            puts "MODEL: #{model_name}"
            puts "MESSAGE: #{e.message}"
            puts "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
            print "\e[0m"
            puts ""
    
            raise RegisterError.new
          end
        end
      end
    
      def insert_record sym_block, str_model, config_data, model_cache
        # col_arr: [:col1, :col2, :col3]
        col_arr = config_data[:col].keys
        # seed_arr: [[elem1, elem2, elem3...]]
        seed_arr = config_data[:col].map{|_, val| val }.transpose
        validate = config_data[:validate].nil? ? false : config_data[:validate]
    
        model_cache[str_model][:model].import(col_arr, seed_arr, validate: validate, timestamps: false)
      end

      def output_log log
        return if log.nil?
        puts log
      end
    
      DUSH_OPTION = /^.*\'$/
      def is_dush? val
        return false unless val.kind_of?(String)
        DUSH_OPTION =~ val
      end
    end
  end
end