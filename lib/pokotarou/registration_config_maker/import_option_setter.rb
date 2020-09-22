require "pokotarou/additional_methods/main"
module Pokotarou
  module RegistrationConfigMaker
    class ImportOptionSetter
      class << self
        def set all_content
          ::Pokotarou::AdditionalMethods::Main.import_from_yml(all_content[:"import'"])
          all_content.delete(:"import'")
        end
      end
    end
  end
end