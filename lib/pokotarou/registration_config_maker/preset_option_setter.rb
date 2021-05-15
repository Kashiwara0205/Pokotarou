require "pokotarou/registration_config_maker/config_domain.rb"
module Pokotarou
  module RegistrationConfigMaker
    class PresetError < StandardError; end
    class PresetOptionSetter
      class << self
        def set all_content
          new_preset_config = {}
          preset_path = []
          all_content[:"preset_path'"].each do |path|
            YAML.load_file(path).deep_symbolize_keys!.each do |preset|
              if :"preset_path'" == preset.first
                preset_path.concat(preset.second)
              else
                new_preset_config[preset.first] = preset.second
              end
            end
          end

          # preset_pathを更新
          all_content.delete(:"preset_path'")
          if preset_path.size != 0
            preset_path.uniq!
            all_content[:"preset_path'"] = preset_path
          end

          # hashの順番を更新するために一度全てのKeyを消す
          copy_config = {}
          all_content.each do |config|
            key = config.first
            value = config.second
            copy_config[key] = value

            all_content.delete(key)
          end
          
          # presetを先に展開する必要があるので、再代入して順番を変更する
          merge(all_content, new_preset_config)
          merge(all_content, copy_config)

          # presetを展開してpresetが入っていた場合には再度展開する
          if all_content.has_key?(:"preset_path'")
            set(all_content, conflicet_hash)
          end

          all_content
        end

        private

        def merge all_content, merge_hash
          merge_hash.each do |config|
            key = config.first
            value = config.second
            if(all_content.has_key?(key))
              print "\e[31m"
              puts "[ERROR]"
              puts "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
              puts "BLOCK: #{key}"
              puts "MESSAGE: Block name conflict has occurred"
              puts "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
              print "\e[0m"
              puts ""
              raise PresetError.new("Block name [ #{key} ] conflict has occurred")
            end
            all_content[key] = value
          end
        end
      end
      
    end
  end
end