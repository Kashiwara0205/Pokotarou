class QueryBuilder
  class << self

    # build insert query
    def insert table_name, col_arr, seed_arr
      col_str = convert_col_to_sql_str(col_arr)
      seed_str = convert_seed_to_sql_str(seed_arr)

      "INSERT INTO #{table_name} #{col_str} VALUES#{seed_str}"
    end

    def convert_to_sql_str arr
      arr_str =
        arr.reduce("(") do |acc, r|
          acc << add_double_quote(r.to_s) << ","
        end
      # remove ' , ' and add ' ) '
      arr_str.chop << ")"
    end

    def convert_seed_to_sql_str seed_arr
      seed_str =
        seed_arr.reduce("") do |acc, r|
          acc << convert_to_sql_str(r) << ","
        end
      # remove ' , '
      seed_str.chop
    end

    def convert_col_to_sql_str col_arr
      col_str =
        col_arr.reduce("(") do |acc, r|
          acc << r.to_s << ","
        end
      # remove ' , ' and add ' ) '
       col_str.chop << ")"
    end

    def add_double_quote str
      "\"" << str << "\""
    end
  end
end