require 'test_helper'

class Pokotarou::NothingResetTest < ActiveSupport::TestCase
  # outline: whether 'import methods function' works
  # expected value: registerd 3 datas
  #                 registerd ["北海道", "青森県", "岩手県"]
  test "import methods" do
    Pokotarou.import("./test/data/methods.rb")
    Pokotarou.execute("test/data/basic/import_methods.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道").present?
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
  end
end