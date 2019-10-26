def pref_array
  ["北海道", "青森県", "岩手県"]
end

def convert_name_to_birthday name
  convert_list = {
    "Tarou" => Date.parse('1997/02/05'),
    "Jirou" => Date.parse('1997/02/04'),
    "Saburou" => Date.parse('1997/02/03')
  }

  name.map{|m| convert_list[m]}
end


def convert_pref_to_test pref_name
  convert_list = {
    "北海道" => "A",
    "青森県" => "B",
    "岩手県" => "C"
  }

  pref_name.map{|m| convert_list[m]}
end