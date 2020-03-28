require "pokotarou/additional_methods.rb"

class DataStructure
  class << self
    def gen data
      execute_template_option_setting(data)
      execute_import_setting(data)
      # return data structure bellow
      # [{ block_name => { model_name => { column_configration }}}, ...]
      data.reduce({}) do |acc, r|
        if is_dush?(r.first.to_s)
          acc[r.first] = r.second
        else
          set_reshape_data_to_acc(acc, r)
        end

        acc
      end
    end

    private

    def execute_import_setting data
      return unless data.has_key?(:"import'")
      AdditionalMethods.import_from_yml(data[:"import'"])
      data.delete(:"import'")
    end

    def execute_template_option_setting data
      return unless data.has_key?(:"template'")
      templates = data[:"template'"]
      data.delete(:"template'")
      data.each do |key, val|
        next if is_dush?(key.to_s)
        set_template_option(val, templates)
      end
    end

    def set_template_option model_data, templates
      model_data.each do |key, val|
        next unless has_template?(val)
        template_name = val[:template]
        template = templates[template_name.to_sym]
        copy_template = template.deep_dup
        # when a new key is generated, it is added behind
        # so, overwrite config_data to template first

        # from val to copy_template
        deep_overwrite(val, copy_template)
        # update config data
        model_data[key] = copy_template
      end
    end

    def deep_overwrite from_hash, to_hash
      from_hash.each do |key, val|
        if val.kind_of?(Hash)
          to_hash[key] ||= {}
          deep_overwrite(val, to_hash[key])
        else
          to_hash[key] = val
        end
      end
    end

    def set_reshape_data_to_acc acc, r
      execute_grouping_option_setting(r.second)
      # r.first is block_name
      # r.second is model_data, like { Pref: {loop: 3}, Member: {loop: 3}... }
      acc[r.first] = gen_structure(r.second)
    end

    def execute_grouping_option_setting model_data
      model_data.each do |key, val|
        set_grouping_option(val) if has_grouping?(val)
      end
    end

    def set_grouping_option val
      val[:grouping].each do |grouping_key, cols|
        apply_grouping_col(:col, val, grouping_key, cols)
        apply_grouping_col(:option, val, grouping_key, cols)
        apply_grouping_col(:convert, val, grouping_key, cols)
      end

      val.delete(:grouping)
    end

    def apply_grouping_col config_name, val, grouping_key, cols
      return if val[config_name].blank?
      return unless val[config_name].has_key?(grouping_key)
      cols.each do |e|
        val[config_name][e.to_sym] = val[config_name][grouping_key]
      end
    
      val[config_name].delete(grouping_key)
    end

    def gen_structure model_data
      model_data.reduce({}) do |acc, r|
        # r.second is config_data, like {loop: 3, ...}
        set_col_type(r.second, r[0].to_s)
        acc[r[0]] = r.second

        acc
      end
    end

    def set_col_type config_data, str_model
      model = eval(str_model)
      foreign_key_data = get_foreign_key_data(model)

      config_data[:col] ||= {}
      model.columns.each do |e|
        symbol_col_name = e.name.to_sym

        unless exists_seed_data?(config_data, symbol_col_name)
          # prepare setting to run default seed
          # set nil to seed data
          config_data[:col][symbol_col_name] = nil

          # set type info
          config_data[:type] ||= {}
          config_data[:type][symbol_col_name] = e.type.to_s

          # set enum info
          config_data[:enum] ||= {}
          if is_enum?(e.sql_type.to_s)
            config_data[:enum][symbol_col_name] =
              e.sql_type.to_s[5..-2].tr("'", "").split(",")
          end

          # set foreign_key info
          if is_foreign_key?(symbol_col_name, foreign_key_data)
            # delete type val for don't run default seeder
            config_data[:type].delete(symbol_col_name)
            # use F function for set foreign key
            config_data[:col][symbol_col_name] = "F|#{foreign_key_data[symbol_col_name].to_s}"
          end
        end

      end
    end

    def get_foreign_key_data model
      associations = model.reflect_on_all_associations(:belongs_to)
      return { } if associations.empty?
      associations.reduce({})do |acc, r|
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
      return false if config_data.blank?
      config_data.has_key?(:grouping)
    end

    def has_template? config_data
      config_data.has_key?(:template)
    end
  end
end