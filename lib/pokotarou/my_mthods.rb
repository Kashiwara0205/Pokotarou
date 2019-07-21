class NothingDataError < StandardError; end


# return rotated val in passed array
def get_rotated_val array, cnt
  raise NothingDataError.new("Nothing seed data") if array.nil?
  size = array.size
  raise NothingDataError.new("Seed data is empty") if size.zero?
  x = (size + cnt) / size
  array[ size + cnt - size * x ]
end