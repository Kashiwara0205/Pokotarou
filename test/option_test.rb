require 'test_helper'

class Pokotarou::OptionTest < ActiveSupport::TestCase
  # outline: whether 'add_id' works
  # expected value: registerd 3 datas
  #                 registerd ["北海道_1", "青森県_2", "岩手県_3"]
  test "add_id option" do
    Pokotarou.execute("test/data/option/add_id_conf.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道_0").present?
    assert_equal true, Pref.where(name: "青森県_1").present?
    assert_equal true, Pref.where(name: "岩手県_2").present?
  end

  # outline: whether 'combine function' works
  # expected value: registerd 3 datas
  #                 registerd ["北海道_1", "青森県_2", "岩手県_3"]
  test "combine option" do
    Pokotarou.execute("test/data/option/combine_option.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道_0").present?
    assert_equal true, Pref.where(name: "北海道_1").present?
    assert_equal true, Pref.where(name: "北海道_2").present?
  end

  # outline: whether 'sequence function' works
  # expected value: registerd 3 datas
  #                 registerd ["北海道_1", "青森県_2", "岩手県_3"]
  test "sequence option" do
    Pokotarou.execute("test/data/option/sequence.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道_0").present?
    assert_equal true, Pref.where(name: "青森県_1").present?
    assert_equal true, Pref.where(name: "岩手県_2").present?
  end
end