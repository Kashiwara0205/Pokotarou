module RegistrationConfigMaker
  class ConfigDomain
    class << self
      def has_dush_import_syntax? all_content
        return false if all_content.blank?
        return all_content.has_key?(:"import'")
      end
  
      def has_dush_template_syntax? all_content
        return false if all_content.blank?
        return all_content.has_key?(:"template'")
      end
  
      def has_grouping_syntax? model_content
        return false if model_content.blank?
        return model_content.has_key?(:grouping)
      end
  
      def has_template_syntax? model_content
        return false if model_content.blank?
        return model_content.has_key?(:template)
      end
  
      def has_seed_data_syntax? col_config, col_name_sym
        return false if col_config.blank?
        return col_config.has_key?(col_name_sym)
      end
  
      DUSH_OPTION_REGEX = /^.*\'$/
      def is_dush_syntax? syntax
        return false unless syntax.kind_of?(String)
        return DUSH_OPTION_REGEX =~ syntax
      end
    end
  end
end