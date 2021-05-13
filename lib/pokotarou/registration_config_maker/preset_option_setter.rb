require "pokotarou/registration_config_maker/config_domain.rb"
module Pokotarou
  module RegistrationConfigMaker
    class PresetOptionSetter
      class << self
        def set all_content
          preset_content = {}
          merged_preset_path = []
          all_content[:"preset_path'"].each do |path|
            YAML.load_file(path).deep_symbolize_keys!.each do |preset|
              if :"preset_path'" == preset.first
                merged_preset_path.concat(preset.second)
              else
                preset_content[preset.first] = preset.second
              end
            end
          end

          # preset_pathを更新
          all_content.delete(:"preset_path'")
          if merged_preset_path.size != 0
            merged_preset_path.uniq!
            all_content[:"preset_path'"] = merged_preset_path
          end

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

          # presetを展開してpresetが入っていた場合には再度展開する
          if all_content.has_key?(:"preset_path'")
            set(all_content)
          end

          all_content
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