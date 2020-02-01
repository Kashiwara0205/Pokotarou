require 'test_helper'
class Pokotarou::ExpriemntsTest < ActiveSupport::TestCase

  test "experiment" do
    #Pokotarou.execute("test/data/experiments/test_1.yml")
=begin
    begin_time = Time.now
    handler = Pokotarou.gen_handler("test/data/experiments/test_2.yml")

    puts "HANDLER:"
    30.times do 
      handler.change_seed(:Default, :Pref, :name, ["茨城県", "栃木県", "沖縄県"])
      Pokotarou.execute(handler.get_data())
    end

    puts "Total: #{Time.now - begin_time}"

    puts "---------------------------------------------------------------------"

    
    begin_time = Time.now
    args = nil
    change = { Default: { Pref: { name: ["茨城県", "栃木県", "沖縄県"] } } }
    file_path = "test/data/experiments/test_2.yml"
    
    batch = [{ file_path: file_path, change: change, args: args }] * 30
    Pokotarou.batch_execute(batch)
    
    puts "BATCH:"
    puts Time.now - begin_time
    
    puts "---------------------------------------------------------------------"
=end
  end
end

