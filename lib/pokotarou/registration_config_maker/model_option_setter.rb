module RegistrationConfigMaker
  class ModelOptionSetter
    class << self
      def set acc, block_content
        block_name = block_content.first
        block_config = block_content.second
        acc[block_name] = {}
  
        block_config.each do |model_content|
          model_name = model_content.first
          model_config = model_content.second
          set_column_type(model_config, model_name)
          acc[block_name][model_name] = model_config
        end
      end
  
      private
  
      def set_column_type model_config, model_name
        model = eval(model_name.to_s)
        foreign_key_data = get_foreign_key_data(model)
  
        model_config[:col] ||= {}
        model.columns.each do |e|
          symbol_col_name = e.name.to_sym
  
          next if ConfigDomain.has_seed_data_syntax?(model_config[:col], symbol_col_name)
  
          # set foreign_key info
          if ColumnDomain.is_foreign_key?(symbol_col_name, foreign_key_data)
            # don't set :type val for don't run default seeder
            # use F function for set foreign key
            model_config[:col][symbol_col_name] = "F|#{foreign_key_data[symbol_col_name].to_s}"
          else
            model_config[:type] ||= {}
            model_config[:type][symbol_col_name] = e.type.to_s
          end
  
          # set enum info
          model_config[:enum] ||= {}
          if ColumnDomain.is_enum?(e.sql_type.to_s)
            model_config[:enum][symbol_col_name] = e.sql_type.to_s[5..-2].tr("'", "").split(",")
          end
   
        end
      end
  
      def get_foreign_key_data model
        relations = model.reflect_on_all_associations(:belongs_to)
        return {} if relations.empty?
        relations.reduce({})do |acc, r|
  
          relation_model = r.name.to_s.camelize
          if Object.const_defined?(relation_model.to_sym)
            acc[r.foreign_key.to_sym] = eval(relation_model)
          end
  
          acc
        end
      end
    end
  end
end