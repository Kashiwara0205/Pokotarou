module Ptool
  class << self
    def gen_br_text
      ["text\ntext"]
    end

    def gen_created_at n = 7, datetime_str = DateTime.now.to_s, with_random_time = false
      datetime = DateTime.parse(datetime_str)
      n.times.reduce([]) do |acc, index|
        hours_num = 0
        minutes_num = 0
        hours_num, minutes_num = get_random_time() if with_random_time

        acc.push(datetime + index.day + hours_num.hours + minutes_num.minutes)

        acc
      end
    end

    def gen_updated_at created_arr, with_random_time = false
      created_arr.each.reduce([]) do |acc, created_datetime|
        hours_num = 5
        minutes_num = 10
        hours_num, minutes_num = get_random_time() if with_random_time

        acc.push(created_datetime + hours_num.hours + minutes_num.minutes)

        acc
      end
    end

    private 

    def get_random_time
      [ rand(24) + 1, second_num = rand(59) + 1]
    end
  end 
end