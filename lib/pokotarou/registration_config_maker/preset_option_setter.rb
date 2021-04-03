require "pokotarou/registration_config_maker/config_domain.rb"
module Pokotarou
  module RegistrationConfigMaker
    class PresetOptionSetter
      class << self
        def set all_content
          preset_content = {}

          all_content[:"preset_path'"].each do |path|
            YAML.load_file(path).deep_symbolize_keys!.each do |preset|
                preset_content[preset.first] = preset.second
            end
          end

          # 使用済みのKeyなので削除
          all_content.delete(:"preset_path'")
          
          # hashの順番を更新するために一度全てのKeyを消す
          tmp = {}
          all_content.each do |config|
            key = config.first
            value = config.second
            tmp[key] = value

            all_content.delete(key)
          end
          
          # presetを先に展開する必要があるので、再代入して順番を変更する
          merge(all_content, preset_content)
          merge(all_content, tmp)
        end

        private
        def merge all_content, merge_hash
          merge_hash.each do |config|
            key = config.first
            value = config.second
            all_content[key] = value
          end
        end
      end
      
    end
  end
end