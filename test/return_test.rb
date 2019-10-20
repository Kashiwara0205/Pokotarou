require 'test_helper'

class Pokotarou::ReturnTest < ActiveSupport::TestCase

  # outline: whether 'add_id' works
  # expected value: return vale ["北海道", "青森県", "岩手県"]
  test "return" do
    return_val = 
      Pokotarou.execute("test/data/return/return.yml")
      assert_equal return_val, ["北海道", "青森県", "岩手県"]
  end
end