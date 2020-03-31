require 'test_helper'

class Pokotarou::ReturnTest < ActiveSupport::TestCase
  def setup
    # reset import method dataes
    Pokotarou.reset
  end

  # outline: whether 'return' works
  # expected value: return vale ["北海道", "青森県", "岩手県"]
  test "return" do
    return_val = 
      Pokotarou.execute("test/data/return/return.yml")
      assert_equal ["北海道", "青森県", "岩手県"], return_val
  end

  # outline: whether 'return' works about maked_col
  # expected value: return vale [1, 2, 3, 4, 5, 6]
  test "return(maked_col)" do
    return_val = 
      Pokotarou.execute("test/data/return/maked_col.yml")
      assert_equal [1, 2, 3, 4, 5, 6], return_val
  end

  # outline: whether 'return' works about C|Model|column_name
  # expected value: return vale ["北海道", "青森県", "岩手県", "北海道", "青森県", "岩手県"]
  test "return(C|Model|column_name)" do
    Pokotarou.execute("test/data/return/column_insert_function/one.yml")

    return_val = 
      Pokotarou.execute("test/data/return/column_insert_function/two.yml")

    assert_equal ["北海道", "青森県", "岩手県", "北海道", "青森県", "岩手県"], return_val
  end

  # outline: whether 'return' works about F|Model
  # expected value: return vale [1, 2, 3, 4, 5, 6]
  test "return(F|Model)" do
    Pokotarou.execute("test/data/return/foreign_key_function/one.yml")
    
    return_val = 
      Pokotarou.execute("test/data/return/foreign_key_function/two.yml")

      assert_equal [1, 2, 3, 4, 5, 6], return_val
  end

  # outline: whether 'return' works about maked
  # expected value: return vale [1, 2, 3, 4, 5, 6]
  test "return(maked)" do 
    return_val = 
      Pokotarou.execute("test/data/return/maked.yml")

    assert_equal [1, 2, 3], return_val
  end
end