require 'test_helper'
class Pokotarou::ComplexTest < ActiveSupport::TestCase

  # outline: whether 'convert nil[0..0] and add_id' works when nothing col
  # expected value: registerd 3 datas
  #                 registerd [nil, "青森県_1", "岩手県_2"]
  test "convert nil(nil[0..0] and add_id)" do
    Pokotarou.execute("test/data/complex/add_id_and_nil.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: nil).present?
    assert_equal true, Pref.where(name: "青森県_1").present?
    assert_equal true, Pref.where(name: "岩手県_2").present?
  end
end