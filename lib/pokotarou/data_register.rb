class RegistError < StandardError; end
class SeedError < StandardError; end

class DataRegister
  class << self
    def regist data
      # init maked to accumulate maded data
      maked = Hash.new
      # init model_data to cache data of model
      model_cache = Hash.new
      ActiveRecord::Base.transaction do
        begin
          data.each do |sym_block, model_data|
            regist_models(sym_block, model_data, maked, model_cache)
          end
        rescue => e
          raise StandardError.new("#{e.message}")
        end
      end
    end

    private

    def execute model, config_data, table_name, col_arr, seed_arr
      # optimize is more faster than activerecord-import
      # however, sql.conf setting is necessary to use
      if config_data[:optimize] 
        # seed_arr.transpose: [[col1_element, col2_element], [col1_element, col2_element]...]
        insert_query = QueryBuilder.insert(table_name, col_arr, seed_arr.transpose)
        ActiveRecord::Base.connection.execute(insert_query)
      else
        model.import(col_arr, seed_arr.transpose, validate: config_data[:validate], timestamps: false)
      end
    end

    def regist_models sym_block, model_data, maked, model_cache
      model_data.each do |e|
        str_model = e.first.to_s
        save_model_cache(model_cache, str_model)
        # model_data.values is config_data
        config_data = e.second
        # col_arr: [:col1, :col2, :col3]
        col_arr = config_data[:col].keys

        # set expand expression for loop '<>' and ':' and so on...
        set_loop_expand_expression(config_data, maked)
        # if there is no setting data, set default seed data
        set_default_seed(config_data)
        # seed_arr: [[col1_element, col1_element], [col2_element, col2_element]...]
        seed_arr = 
          get_seed_arr(model_cache[str_model][:model], sym_block,
                         model_cache[str_model][:sym_model], config_data, maked)

        output_log(config_data[:log]) 
        begin
          # execute insert
          execute(model_cache[str_model][:model], 
                  config_data, model_cache[str_model][:table_name], col_arr, seed_arr)
        rescue => e
          raise RegistError.new("
            block: #{sym_block}
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
    
    def get_seed_arr model, sym_block, sym_model, config_data, maked
      options = config_data[:option]
      loop_size = config_data[:loop]


      if apply_autoincrement?(config_data[:autoincrement])
        set_autoincrement(config_data, model, loop_size)
      end

      config_data[:col].map do |key, val|
        begin 
          # set expand expression '<>' and ':' and so on...
          set_expand_expression(config_data, key, val, maked)
          expanded_val = config_data[:col][key]
          option_conf = options.nil? ? nil : Option.gen(options[key])
          # Take count yourself, because .with_index is slow
          cnt = 0
          seeds = 
            loop_size.times.map do
              seed = option_conf.nil? ? get_seed(expanded_val, cnt) : get_seed_with_option(expanded_val, option_conf, cnt)
              cnt += 1

              seed
            end
          update_maked_data(maked, sym_block, sym_model, key, seeds)

          seeds
        rescue => e
          raise SeedError.new("
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

    def set_autoincrement config_data, model, loop_size
      last_record = model.last
      # use pluck to optimize(suppress make object)
      additions = model.all.pluck(:id).size + loop_size      
      latest_id = last_record.nil? ? 1 : last_record.id + 1
      config_data[:col][:id] = [*latest_id..additions]
    end

    def set_expand_expression config_data, key, val, maked
      # if it exists type, there is no need for doing 'expand expression'
      return if config_data[:type][key].present?
      config_data[:col][key] = ExpressionParser.parse(val, maked)
    end

    def set_loop_expand_expression config_data, maked
      config_data[:loop] = 
        LoopExpressionParser.parse(config_data[:loop], maked)  
    end

    def get_seed arr, cnt
      get_rotated_val(arr, cnt)
    end

    def get_seed_with_option arr, option, cnt
      Option.apply(arr, option, cnt)
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

  end
end