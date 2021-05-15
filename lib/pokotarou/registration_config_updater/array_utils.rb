module Pokotarou
  class NothingDataError < StandardError; end
  module RegistrationConfigUpdater 
    module ArrayUtils
      # return rotated val in passed array
      def get_rotated_val array, size, cnt
        raise NothingDataError.new("Seed data is empty") if array.nil? || size.zero?
        x = (size + cnt) / size
  
        array[ size + cnt - size * x ]
      end
    end
  end
end