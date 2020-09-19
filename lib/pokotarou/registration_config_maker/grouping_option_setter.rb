module RegistrationConfigMaker
  class GroupingOptionSetter
    class << self
      def set seed_config
          seed_config[:grouping].each do |grouping_key, cols|
          set_grouping_data(:col, seed_config, grouping_key, cols)
          set_grouping_data(:option, seed_config, grouping_key, cols)
          set_grouping_data(:convert, seed_config, grouping_key, cols)
        end
    
        seed_config.delete(:grouping)
      end
    
      private
      def set_grouping_data config_name, seed_config, grouping_key, cols
        return if seed_config[config_name].blank?
        return unless seed_config[config_name].has_key?(grouping_key)
        cols.each do |e|
          seed_config[config_name][e.to_sym] = seed_config[config_name][grouping_key]
        end
        
        seed_config[config_name].delete(grouping_key)
      end
    end
  end
end