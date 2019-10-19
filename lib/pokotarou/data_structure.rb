class DataStructure
  class << self
    def gen data
      # return data structure bellow
      # [{ block_name => { model_name => { column_configration }}}, ...]
      data.reduce(Hash.new) do |acc, r|
        if is_dush?(r.first.to_s)
          acc[r.first] = r.second
        else
          set_reshape_data_to_acc(acc, r)
        end

        acc
      end
    end

    private

    def set_reshape_data_to_acc acc, r
      execute_grouping_option_setting(r.second)
      # r.first is block_name
      # r.second is model_data, like { Pref: {loop: 3}, Member: {loop: 3}... }
      acc[r.first] = gen_structure(r.second)
    end

    def execute_grouping_option_setting model_data
      model_data.each do |key, val|
        if has_grouping?(val)
          set_grouping_option(val)
        end
      end
    end

    def set_grouping_option val
      val[:grouping].each do |grouping_key, cols|
        expand_grouping_col(:col, val, grouping_key, cols)
        expand_grouping_col(:option, val, grouping_key, cols)
      end

      val.delete(:grouping)
    end

    def expand_grouping_col config_name, val, grouping_key, cols
      return unless val[config_name].has_key?(grouping_key)
      cols.each do |e|
        val[config_name][e.to_sym] = val[config_name][grouping_key]
      end
    
      val[config_name].delete(grouping_key)
    end

    def gen_structure model_data
      model_data.reduce(Hash.new) do |acc, r|
        # r.second is config_data, like {loop: 3, ...}
        set_col_type(r.second, r[0].to_s)
        acc[r[0]] = r.second

        acc
      end
    end

    def set_col_type config_data, str_model
      model = eval(str_model)
      foreign_key_data = get_foreign_key_data(model)

      config_data[:col] ||= Hash.new
      model.columns.each do |e|
        symbol_col_name = e.name.to_sym

        unless exists_seed_data?(config_data, symbol_col_name)
          # prepare setting to run default seed
          # set nil to seed data
          config_data[:col][symbol_col_name] = nil

          # set type info
          config_data[:type] ||= Hash.new
          config_data[:type][symbol_col_name] = e.type.to_s

          # set enum info
          config_data[:enum] ||= Hash.new
          if is_enum?(e.sql_type.to_s)
            config_data[:enum][symbol_col_name] =
              e.sql_type.to_s[5..-2].tr("'", "").split(",")
          end

          # set foreign_key info
          config_data[:foreign_key] ||= Hash.new
          if is_foreign_key?(symbol_col_name, foreign_key_data)
            config_data[:foreign_key][symbol_col_name] = foreign_key_data[symbol_col_name]
          end
        end

      end
    end

    def get_foreign_key_data model
      associations = model.reflect_on_all_associations(:belongs_to)
      return { } if associations.empty?
      associations.reduce(Hash.new)do |acc, r|
        model = r.name.to_s.camelize
        if Object.const_defined?(model.to_sym)
          acc[r.foreign_key.to_sym] = eval(model)
        end

        acc
      end
    end

    def is_foreign_key? symbol_col_name, foreign_key_data
      foreign_key_data[symbol_col_name].present?
    end

    def exists_seed_data? config_data ,symbol_col_name
      config_data[:col].has_key?(symbol_col_name)
    end

    ENUM = /^enum(\s*.)*$/
    def is_enum? val
      return false unless val.kind_of?(String)
      ENUM =~ val
    end

    DUSH_OPTION = /^.*\'$/
    def is_dush? val
      return false unless val.kind_of?(String)
      DUSH_OPTION =~ val
    end
    
    def has_grouping? config_data
      config_data.has_key?(:grouping)
    end
  end
end