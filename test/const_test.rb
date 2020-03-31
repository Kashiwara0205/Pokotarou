require 'test_helper'
class Pokotarou::ConstTest < ActiveSupport::TestCase
  def setup
    # reset import method dataes
    Pokotarou.reset
  end

  # outline: whether correctly use const variables in yml
  # expected value: registerd 3 datas
  #                 registerd ["北海道", "青森県", "岩手県"]
  test "def valiables" do
    Pokotarou.execute("test/data/const/variables.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道").present?
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
  end

  # outline: whether correctly use expression variables in yml
  # expected value: registerd 3 datas
  #                 registerd ["北海道", "青森県", "岩手県"]
  test "def expression" do
    Pokotarou.execute("test/data/const/expression.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道").present?
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
  end
end