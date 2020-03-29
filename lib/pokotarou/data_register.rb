require "pokotarou/additional_variables/additional_variables.rb"

class RegisterError < StandardError; end
class SeedError < StandardError; end

class DataRegister
  class << self
    def register data
      # init maked to accumulate maded data
      maked = {}
      maked_col = {}
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

    def register_val_by_bulk sym_block, model_data, maked, model_cache, maked_col
      model_data.each do |e|
        begin
          str_model = e.first.to_s
          save_model_cache(model_cache, str_model)

          model = model_cache[str_model][:model]
          sym_model = model_cache[str_model][:sym_model]
          # model_data.values is config_data
          config_data = e.second
          # set expand expression for loop '<>' and ':' and so on...
          set_loop_expand_expression(config_data, maked, maked_col)
          # if there is no setting data, set default seed data
          set_default_seed(config_data)
          # seed_arr: [[col1_element, col1_element], [col2_element, col2_element]...]
          set_seed_arr(model, sym_block, sym_model, config_data, maked, maked_col)

          output_log(config_data[:log])
          insert_record(sym_block, str_model, config_data ,model_cache)
        rescue => e
          print "\e[31m"
          puts "[Pokotarou ERROR]"
          puts "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
          puts "Failed Register record"
          puts "BLOCK: #{sym_block}"
          puts "MODEL: #{str_model}"
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
      model_cache[str_model][:model].import(col_arr, seed_arr, validate: config_data[:validate], timestamps: false)
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

    def set_seed_arr model, sym_block, sym_model, config_data, maked, maked_col
      options = config_data[:option]
      convert_conf = config_data[:convert]
      loop_size = config_data[:loop]

      if apply_autoincrement?(config_data[:autoincrement])
        prev_id_arr =
          if maked_col[sym_model].present? && maked_col[sym_model].has_key?(:id)
            maked_col[sym_model][:id]
          else
            []
          end

        set_autoincrement(config_data, model, loop_size, prev_id_arr)
      end

      # set variables
      if config_data.has_key?(:let)
        AdditionalVariables.set_let(config_data)
      end
          
      config_data[:col].each do |key, val|
        begin
          # set expand expression '<>' and ':' and so on...
          set_expand_expression(config_data, key, val, maked, maked_col)
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

      AdditionalVariables.remove_let()
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

    def set_expand_expression config_data, key, val, maked, maked_col
      # if it exists type, there is no need for doing 'expand expression'
      return if config_data[:type][key].present?
      config_data[:col][key] = SeedExpressionParser.parse(val, maked, maked_col)
    end

    def set_loop_expand_expression config_data, maked, maked_col
      config_data[:loop] =
        LoopExpressionParser.parse(config_data[:loop], maked, maked_col)
    end

    def get_seed arr, size, cnt
      ArrayOperation.get_rotated_val(arr, size, cnt)
    end

    def get_seed_with_option arr, size, option, cnt
      Option.apply(arr, size, option, cnt)
    end

    def update_maked_data maked, sym_block, sym_model, col, seed
      # maked: { key: Model, value: {key: col1, val: [col1_element, col1_element]} }
      maked[sym_block] ||= {}
      maked[sym_block][sym_model] ||= {}
      maked[sym_block][sym_model][col] = seed
    end

    def update_maked_col maked_col, sym_model, column, vals
      maked_col[sym_model] ||= {}
      maked_col[sym_model][column] ||= []
      maked_col[sym_model][column].concat(vals)

      maked_col
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