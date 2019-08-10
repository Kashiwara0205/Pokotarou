class NothingDataError < StandardError; end
class ArrayOperation
  class << self
    # return rotated val in passed array
    def get_rotated_val array, size, cnt
      raise NothingDataError.new("Nothing seed data") if array.nil?
      raise NothingDataError.new("Seed data is empty") if size.zero?
      x = (size + cnt) / size

      array[ size + cnt - size * x ]
    end
  end
end
