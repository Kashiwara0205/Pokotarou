require "pokotarou/registration_config_maker/config_domain.rb"
module RegistrationConfigMaker
  class TemplateOptionSetter
    class << self
      def set all_content
        templates = fetch_template_option(all_content)

        all_content.each do |key, block_content|
          next if ConfigDomain.is_dush_syntax?(key.to_s)
          set_template_option(block_content, templates)
        end
      end
    
      private

      def fetch_template_option all_content
        templates = ConfigDomain.has_dush_template_syntax?(all_content) ? all_content.delete(:"template'") : {}

        if ConfigDomain.has_dush_template_path_syntax?(all_content)
          merge_template_from_template_path(all_content, templates)
        end

        return templates 
      end

      def merge_template_from_template_path all_content, templates
        template_path = all_content.delete(:"template_path'")
        template_path.each do |e|
          YAML.load_file(e).deep_symbolize_keys!.each do |loaded_template|
            templates[loaded_template.first] = loaded_template.second
          end
        end
      end
  
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