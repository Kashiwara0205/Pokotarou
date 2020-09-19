require "pokotarou/registration_config_maker/config_domain.rb"
module RegistrationConfigMaker
  class TemplateOptionSetter
    class << self
      def set all_content
        templates = all_content.delete(:"template'")
        all_content.each do |key, block_content|
          next if ConfigDomain.is_dush_syntax?(key.to_s)
          set_template_option(block_content, templates)
        end
      end
    
      private
  
      def set_template_option block_content, templates
        block_content.each do |key, model_content|
          next unless ConfigDomain.has_template_syntax?(model_content)
          template_copy = get_template_copy(model_content[:template], templates)
          deep_overwrite(model_content, template_copy)
          # update config all_config
          block_content[key] = template_copy
        end
      end
  
      def get_template_copy template_name, templates
        return templates[template_name.to_sym].deep_dup
      end
    
      def deep_overwrite source, destination
        source.each do |key, val|
          if val.kind_of?(Hash)
            destination[key] ||= {}
            deep_overwrite(val, destination[key])
          else
            destination[key] = val
          end
        end
      end
    end
  end
end