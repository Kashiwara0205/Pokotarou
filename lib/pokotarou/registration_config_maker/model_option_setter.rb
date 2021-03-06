module Pokotarou
  module RegistrationConfigMaker
    class UnexistsModelError < StandardError; end
    class UnexistsModelConfigError < StandardError; end
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
          begin
            model = eval_model(model_name)
            foreign_key_data = get_foreign_key_data(model)

            if model_config.nil?
              raise UnexistsModelConfigError.new("Unexists model config")
            end
    
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
          rescue UnexistsModelError => e
            print "\e[31m"
            puts "[ERROR]"
            puts "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
            puts "MESSAGE: Unexists Model #{model_name.to_s}"
            puts "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
            print "\e[0m"
            puts ""
            
            raise e
          rescue UnexistsModelConfigError => e
            print "\e[31m"
            puts "[ERROR]"
            puts "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
            puts "MESSAGE: Unexists model config #{model_name.to_s}"
            puts "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
            print "\e[0m"
            puts ""
            
            raise e
          rescue => e
            print "\e[31m"
            puts "[ERROR]"
            puts "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
            puts "MESSAGE: This model config is broken"
            puts "         #{e}"
            puts "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
            print "\e[0m"
            puts ""

            raise e
          end
        end

        def eval_model model_name
          begin
            eval(model_name.to_s)
          rescue
            raise UnexistsModelError.new("Unexists Model #{model_name.to_s} ")
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
end