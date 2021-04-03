require "pokotarou/registration_config_maker/column_domain.rb"
require "pokotarou/registration_config_maker/config_domain.rb"
require "pokotarou/registration_config_maker/import_option_setter.rb"
require "pokotarou/registration_config_maker/template_option_setter.rb"
require "pokotarou/registration_config_maker/grouping_option_setter.rb"
require "pokotarou/registration_config_maker/model_option_setter.rb"
require "pokotarou/registration_config_maker/preset_option_setter.rb"

module Pokotarou
  module RegistrationConfigMaker
    class Main
      class << self
        def gen all_content
          set_header_config(all_content)
          all_content.reduce({}) do |acc, block_content|
            block_name = block_content.first
            block_config = block_content.second
  
            if ConfigDomain.is_dush_syntax?(block_name.to_s)
              acc[block_name] = block_config
            else
              set_model_config_to_acc(acc, block_content)
            end
  
            acc
          end
        end
  
        private
  
        def set_header_config all_content
          set_template_option(all_content)
          set_preset_option(all_content)
          set_import_option(all_content)
        end
  
        def set_import_option all_content
          return unless ConfigDomain.has_dush_import_syntax?(all_content)
          ImportOptionSetter.set(all_content)
        end

        def set_preset_option all_content
          return all_content unless ConfigDomain.has_dush_preset_path_syntax?(all_content)
          PresetOptionSetter.set(all_content)
        end
  
        def set_template_option all_content
          return if !ConfigDomain.has_dush_template_syntax?(all_content) && !ConfigDomain.has_dush_template_path_syntax?(all_content)
          TemplateOptionSetter.set(all_content)
        end
  
        def set_model_config_to_acc acc, block_content
          set_grouping_option(block_content.second)
          ModelOptionSetter.set(acc, block_content)
        end
  
        def set_grouping_option block_content
          block_content.each do |_, model_content|
            GroupingOptionSetter.set(model_content) if ConfigDomain.has_grouping_syntax?(model_content)
          end
        end
      end
    end
  end
end