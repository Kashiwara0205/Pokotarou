require "pokotarou/expression_parser.rb"
require "pokotarou/registration_config_updater/default_value_maker.rb"
require "pokotarou/registration_config_updater/option_config.rb"
require "pokotarou/registration_config_updater/convert_config.rb"
require "pokotarou/registration_config_updater/array_utils.rb"

module RegistrationConfigUpdater
  class Main
    class << self
        
      include ArrayUtils

      def update model_content, block_name_sym, model_cache, maked, maked_col
        model_name = model_content.first.to_s
        model_config = model_content.second
        update_model_cache(model_cache, model_name)

        model = model_cache[model_name][:model]
        model_name_sym = model_cache[model_name][:sym_model]
        set_loop_expand_expression(model_config, maked, maked_col)
        set_default_seed(model_config)
        set_seed_arr(model, block_name_sym, model_name_sym, model_config, maked, maked_col)
      end

      private
      def set_loop_expand_expression model_config, maked, maked_col
        model_config[:loop] =
          LoopExpressionParser.parse(model_config[:loop], maked, maked_col)
      end

      def set_default_seed model_config
        # each column type, key is symbolize column name
        model_config[:type].each do |key, _|
          # if it is id, skip
          next if :id == key
          # if there is data already, skip
          next if model_config[:col][key].present?
  
          model_config[:col][key] = DefaultValueMaker.make(model_config, key)
        end
      end  

      def update_model_cache model_cache, model_name
        return if model_cache[model_name].present?
        model = eval(model_name)
        model_cache[model_name] = {
          model: model,
          sym_model: model_name.to_sym,
          table_name: model.table_name
        }
      end

      def set_seed_arr model, sym_block, sym_model, config_data, maked, maked_col
        options = config_data[:option]
        convert_conf = config_data[:convert]
        loop_size = config_data[:loop]
  
        if has_autoincrement_config?(config_data[:autoincrement])
          prev_id_arr =
            if maked_col[sym_model].present? && maked_col[sym_model].has_key?(:id)
              maked_col[sym_model][:id]
            else
              []
            end
  
          set_autoincrement(config_data, model, loop_size, prev_id_arr)
        end
  
        config_data[:col].each do |key, val|
          begin
            # set expand expression '<>' and ':' and so on...
            set_expand_expression(config_data, key, val, maked, maked_col)
            expanded_val = config_data[:col][key]
            expanded_val_size = expanded_val.size
  
            # apply converter
            if convert_conf.present?
              expanded_val = ConvertConfig.execute(expanded_val, convert_conf[key])
            end
  
            # get option configration
            option_conf = OptionConfig.fetch(options, key)
  
            # Take count yourself, because .with_index is slow
            cnt = 0
            seeds =
              loop_size.times.map do
                seed = 
                  option_conf.nil? ? get_rotated_val(expanded_val, expanded_val_size, cnt) : get_seed_with_option(expanded_val, expanded_val_size, option_conf, cnt)
                cnt += 1
  
                seed
              end
  
            update_maked_data(maked, sym_block, sym_model, key, seeds )
            update_maked_col(maked_col, sym_model, key, config_data[:col][key])
            config_data[:col][key] = seeds
          rescue => e
            print "\e[31m"
            puts "[Pokotarou ERROR]"
            puts "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
            puts "Failed Generating seed"
            puts "BLOCK: #{sym_block}"
            puts "MODEL: #{sym_model}"
            puts "COLUMN: #{key}"
            puts "MESSAGE: #{e.message}"
            puts "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
            print "\e[0m"
            puts ""
  
            raise SeedError.new
          end
        end
      end
  
      def has_autoincrement_config? autoincrement_flg
        # default true
        return true if autoincrement_flg.nil?
        autoincrement_flg
      end
  
      def set_autoincrement config_data, model, loop_size, prev_id_arr
        max_id = model.maximum(:id)
  
        current_id =
          if prev_id_arr.present?
            prev_id_arr.last
          elsif max_id.nil?
            0
          else
            max_id
          end
  
        additions = current_id + loop_size
        next_id = current_id + 1
  
        ids = [*next_id..additions]
        ids.shuffle! if config_data[:randomincrement]
        config_data[:col][:id] = ids
      end
  
      def set_expand_expression config_data, key, val, maked, maked_col
        # if it exists type, there is no need for doing 'expand expression'
        return if config_data[:type][key].present?
        config_data[:col][key] = SeedExpressionParser.parse(val, maked, maked_col)
      end
  

      def get_seed_with_option arr, size, option, cnt
        OptionConfig.execute(arr, size, option, cnt)
      end
  
      def update_maked_data maked, sym_block, sym_model, col, seed
        # maked: { key: Model, value: {key: col1, val: [col1_element, col1_element]} }
        maked[sym_block][sym_model][col] = seed
      end
  
      def update_maked_col maked_col, sym_model, column, vals
        maked_col[sym_model][column] ||= []
        maked_col[sym_model][column].concat(vals)
      end
  
    end
  end
end