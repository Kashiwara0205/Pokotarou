class RegistError < StandardError; end
class SettingError < StandardError; end
class SeedError < StandardError; end

class DataRegister
  class << self
    def register data
      # init maked to accumulate maded data
      maked = Hash.new
      # init model_data to cache data of model
      model_cache = Hash.new
      autoincrement_id_hash = Hash.new
      ActiveRecord::Base.transaction do
        begin
          data.each do |sym_block, model_data|
            next if is_dush?(sym_block.to_s)
            setting_register_val_for_bulk(sym_block, model_data, maked, model_cache, autoincrement_id_hash)
          end
          bulk_hash = merge_block(data)
          register_by_bulk(bulk_hash, model_cache)
        rescue => e
          raise StandardError.new("#{e.message}")
        end
      end

      ReturnExpressionParser.parse(data[:"return'"], maked) 
    end

    private

    def merge_block data
      bulk_hash = {}
      data.each do |block, val|
        next if is_dush?(block.to_s)
        val.each do |model, config|
          if bulk_hash[model].nil?
            bulk_hash[model] = config
          else
            merge_loop(model, config, bulk_hash) if config[:loop].present?
            merge_seed_data(model, config, bulk_hash) if config[:col].present?
          end
        end
      end

      bulk_hash
    end

    def merge_loop model, config, bulk_hash
      bulk_hash[model][:loop] += config[:loop]
    end

    def merge_seed_data model, config, bulk_hash
      config[:col].each do |col_name, seed|
        bulk_hash[model][:col][col_name].concat(seed)
      end
    end

    def setting_register_val_for_bulk sym_block, model_data, maked, model_cache, autoincrement_id_hash
      begin
        model_data.each do |e|
          str_model = e.first.to_s
          save_model_cache(model_cache, str_model)

          model = model_cache[str_model][:model]
          sym_model = model_cache[str_model][:sym_model]

          # model_data.values is config_data
          config_data = e.second
          # col_arr: [:col1, :col2, :col3]
          col_arr = config_data[:col].keys

          # set expand expression for loop '<>' and ':' and so on...
          set_loop_expand_expression(config_data, maked, autoincrement_id_hash)
          # if there is no setting data, set default seed data
          set_default_seed(config_data)
          # seed_arr: [[col1_element, col1_element], [col2_element, col2_element]...]
          set_seed_arr(model, sym_block, sym_model, config_data, maked, autoincrement_id_hash)

          output_log(config_data[:log]) 
        end
      rescue => e
        raise SettingError.new("
          Failed setting for bulk insert...

          block: #{sym_block}
          model: #{str_model}
          message: #{e.message}
        ")
      end
    end

    def register_by_bulk bulk_hash, model_cache
      bulk_hash.each do |e|
        str_model = e.first.to_s
        # model_data.values is config_data
        config_data = e.second
        # col_arr: [:col1, :col2, :col3]
        col_arr = config_data[:col].keys
        # seed_arr: [[elem1, elem2, elem3...]]
        seed_arr = config_data[:col].map{|_, val| val }.transpose

        begin
          model_cache[str_model][:model].import(col_arr, seed_arr, validate: config_data[:validate], timestamps: false)
        rescue => e
          raise RegistError.new("
            Failed bulk insert...

            model: #{str_model}
            message: #{e.message}
          ")
        end
      end
    end

    def save_model_cache model_cache, str_model
      return if model_cache[str_model].present?
      model = eval(str_model)
      model_cache[str_model] = {
        model: model,
        sym_model: str_model.to_sym,
        table_name: model.table_name
      }
    end

    def set_default_seed config_data
      block = ->(symbol){ :id == symbol }
      # each column type, key is symbolize column name
      config_data[:type].each do |key, _|
        # if it is id, skip
        next if block.call(key)
        # if there is data already, skip
        next if config_data[:col][key].present?

        config_data[:col][key] = Seeder.gen(config_data, key) 
      end
    end
    
    def set_seed_arr model, sym_block, sym_model, config_data, maked, autoincrement_id_hash
      options = config_data[:option]
      convert_conf = config_data[:convert]
      loop_size = config_data[:loop]

      if apply_autoincrement?(config_data[:autoincrement])
        set_autoincrement(config_data, model, loop_size, autoincrement_id_hash[sym_model])
        # update_latest_id
        autoincrement_id_hash[sym_model] = config_data[:col][:id]
      end

      config_data[:col].each do |key, val|
        begin 
          # set expand expression '<>' and ':' and so on...
          set_expand_expression(config_data, key, val, maked, autoincrement_id_hash)
          expanded_val = config_data[:col][key]
          expanded_val_size = expanded_val.size

          # apply converter
          if convert_conf.present?
            expanded_val = Converter.convert(expanded_val, convert_conf[key])
          end

          # get option configration
          option_conf = options.nil? ? nil : Option.gen(options[key])

          # Take count yourself, because .with_index is slow
          cnt = 0
          seeds = 
            loop_size.times.map do
              seed =
                option_conf.nil? ? get_seed(expanded_val, expanded_val_size, cnt) : get_seed_with_option(expanded_val, expanded_val_size, option_conf, cnt)
              cnt += 1

              seed
            end
          update_maked_data(maked, sym_block, sym_model, key, seeds )
          
          config_data[:col][key] = seeds
        rescue => e
          raise SeedError.new("
            Failed generate seed data...
            block: #{sym_block}
            model: #{sym_model}
            column: #{key}
            message: #{e.message}
          ")
        end
      end
    end

    def apply_autoincrement? autoincrement_flg
      # default true
      return true if autoincrement_flg.nil?
      autoincrement_flg
    end

    def set_autoincrement config_data, model, loop_size, prev_id_arr
      last_record = model.last
      current_id = 
        if prev_id_arr.present?
          prev_id_arr.last
        elsif last_record.nil?
          0
        else
          last_record.id
        end
      
      additions = current_id + loop_size
      next_id = current_id + 1

      config_data[:col][:id] = [*next_id..additions]
    end

    def set_expand_expression config_data, key, val, maked, autoincrement_id_hash
      # if it exists type, there is no need for doing 'expand expression'
      return if config_data[:type][key].present?
      config_data[:col][key] = SeedExpressionParser.parse(val, maked, autoincrement_id_hash)
    end

    def set_loop_expand_expression config_data, maked, autoincrement_id_hash
      config_data[:loop] = 
        LoopExpressionParser.parse(config_data[:loop], maked, autoincrement_id_hash)  
    end

    def get_seed arr, size, cnt
      ArrayOperation.get_rotated_val(arr, size, cnt)
    end

    def get_seed_with_option arr, size, option, cnt
      Option.apply(arr, size, option, cnt)
    end

    def update_maked_data maked, sym_block, sym_model, col, seed
      # maked: { key: Model, value: {key: col1, val: [col1_element, col1_element]} }
      maked[sym_block] ||= Hash.new
      maked[sym_block][sym_model] ||= Hash.new
      maked[sym_block][sym_model][col] = seed
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