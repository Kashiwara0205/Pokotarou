# description: return rotated val in passed array
def get_rotated_val array, cnt
  size = array.size
  x = (size + cnt) / size
  array[ size + cnt - size * x ]
end