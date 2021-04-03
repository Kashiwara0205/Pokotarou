require 'test_helper'

class Pokotarou::PresetTest < ActiveSupport::TestCase  
  # outline: should works preset function
  # expected value: registerd 3 pref data 
  #                 registerd 1 member data
  test "check preset function" do
    Pokotarou.execute("test/data/preset/one.yml")

    assert_equal 3, Pref.all.count
    assert Pref.find_by(name: "北海道").present?
    assert Pref.find_by(name: "青森県").present?
    assert Pref.find_by(name: "岩手県").present?

    assert_equal 1, Member.all.count
    assert Member.find_by(name: "hoge").present?
  end

  # outline: should works multiple preset function
  # expected value: registerd 3 pref data 
  #                 registerd 3 member data
  test "check multiple preset function" do
    Pokotarou.execute("test/data/preset/multiple.yml")

    assert_equal 3, Pref.all.count
    assert Pref.find_by(name: "北海道").present?
    assert Pref.find_by(name: "青森県").present?
    assert Pref.find_by(name: "岩手県").present?

    assert_equal 3, Member.all.count
    assert Member.find_by(name: "hoge").present?
    assert Member.find_by(name: "PresetMember1").present?
    assert Member.find_by(name: "PresetMember2").present?
  end
end