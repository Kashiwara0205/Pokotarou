require 'test_helper'

class Pokotarou::YmlTest < ActiveSupport::TestCase

  def setup
    # reset import method dataes
    Pokotarou.reset
  end

  test "truth" do
    assert_kind_of Module, Pokotarou
  end

  # outline: whether pokotarou can register with the minimum settings
  # expected value: registerd 3 datas
  test "nothing" do
    Pokotarou.execute("test/data/yml/function/nothing_conf.yml")
    assert_equal 3, Pref.all.count
  end

  # outline: whether pokotarou can register with the same model
  # expected value: registerd 6 datas
  test "same model" do
    Pokotarou.execute("test/data/yml/function/same_model_conf.yml")
    assert_equal 6, Pref.all.count
  end

  # outline: whether 'autoincrement' works
  # expected value: registerd 6 datas
  #                 registed autoincrement_id
  test "autoincrement_id" do
    Pokotarou.execute("test/data/yml/function/nothing_conf.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(id: 1).present?
    assert_equal true, Pref.where(id: 2).present?
    assert_equal true, Pref.where(id: 3).present?
    Pokotarou.execute("test/data/yml/function/nothing_conf.yml")
    assert_equal 6, Pref.all.count
    assert_equal true, Pref.where(id: 4).present?
    assert_equal true, Pref.where(id: 5).present?
    assert_equal true, Pref.where(id: 6).present?
  end

  # outline: whether 'autoincrement = false' works
  # expected value: registerd 3 datas
  #                 registed autoincrement_id
  test "no autoincrement_id" do
    Pokotarou.execute("test/data/yml/function/no_autoincrement.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(id: 100).present?
    assert_equal true, Pref.where(id: 101).present?
    assert_equal true, Pref.where(id: 102).present?
  end

  # outline: whether pokotarou can register with the setting array
  # expected value: registerd 3 datas
  #                 registerd ["北海道", "青森県", "岩手県"]
  test "insert setting array" do
    Pokotarou.execute("test/data/yml/function/array_insert.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道").present?
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
  end

  # outline: whether pokotarou can register with the setting string
  # expected value: registerd 3 datas
  #                 registerd "北海道"
  test "insert setting string" do
    Pokotarou.execute("test/data/yml/function/string_insert.yml")
    assert_equal 1, Pref.all.count
    assert_equal 1, Pref.where(name: "北海道").count
  end

  # outline: whether 'add_id' works
  # expected value: registerd 3 datas
  #                 registerd ["北海道_1", "青森県_2", "岩手県_3"]
  test "add_id option" do
    Pokotarou.execute("test/data/yml/option/add_id_conf.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道_0").present?
    assert_equal true, Pref.where(name: "青森県_1").present?
    assert_equal true, Pref.where(name: "岩手県_2").present?
  end

  # outline: whether pokotarou can register with the foreign key
  # expected value: registerd 6 datas(pref: 3, member: 3)
  test "foreign_key" do
    Pokotarou.execute("test/data/yml/function/foreign_key_insert.yml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Member.all.count
    assert_equal Pref.all.pluck(:id), Member.all.pluck(:pref_id)
  end

  # outline: whether pokotarou can register with the expression_expansion
  # expected value: registerd 3 datas
  #                 created_at: DateTime.parse("1997/02/05")
  test "expression_expansion" do
    Pokotarou.execute("test/data/yml/function/expression_expansion.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道").present?
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
    assert_equal 3, Pref.where(created_at: DateTime.parse("1997/02/05")).count
  end

  # outline: whether 'default seeder function' works
  # expected value: registerd 3 datas
  test "default seeder" do
    Pokotarou.execute("test/data/yml/function/default_seeder.yml")
    assert_equal 3, TestModel.all.count
  end

  # outline: whether 'maked function' works
  # expected value: registerd 3 datas
  test "maked" do
    Pokotarou.execute("test/data/yml/function/maked/once.yml")
    assert_equal 2, Member.all.count
    assert_equal true, Member.where(name: "北海道").present?
    assert_equal true, Member.where(name: "青森県").present?
  end

  # outline: whether 'maked function' works when written twice in a row
  # expected value: registerd 4 datas
  test "maked(twice)" do
    Pokotarou.execute("test/data/yml/function/maked/twice.yml")
    assert_equal 4, Member.all.count
    assert_equal true, Member.where(name: "北海道").present?
    assert_equal true, Member.where(name: "青森県").present?
    assert_equal true, Member.where(name: "秋田県").present?
    assert_equal true, Member.where(name: "茨城県").present?
  end

  # outline: whether 'maked function' works when written in same model
  # expected value: registerd 3 datas
  test "maked(same model)" do
    Pokotarou.import("./test/data/methods.rb")
    Pokotarou.execute("test/data/yml/function/maked/same_model.yml")
    assert_equal 3, Member.all.count

    tarou = Member.find_by(name: "Tarou")
    assert_equal "Tarou", tarou.remarks
    assert_equal Date.parse('1997/02/05'), tarou.birthday

    jirou = Member.find_by(name: "Jirou")
    assert_equal "Jirou", jirou.remarks
    assert_equal Date.parse('1997/02/04'), jirou.birthday

    saburou = Member.find_by(name: "Saburou")
    assert_equal "Saburou", saburou.remarks
    assert_equal Date.parse('1997/02/03'), saburou.birthday
  end

  # outline: whether 'maked function' works when used other blocks
  # expected value: registerd 3 datas
  test "maked(other block)" do
    Pokotarou.execute("test/data/yml/function/maked/other_block.yml")
    assert_equal 2, Member.all.count
    assert_equal true, Member.where(name: "北海道").present?
    assert_equal true, Member.where(name: "青森県").present?
  end

  # outline: whether 'expression_expansion' of loop works
  # expected value: registerd 3 datas
  test "expression_expansion of loop" do
    Pokotarou.execute("test/data/yml/function/loop_expression_expansion.yml")
    assert_equal 3, Member.all.count
  end

  # outline: whether 'escape function' of loop works
  # expected value: registerd escaped str data
  test "escape" do
    Pokotarou.execute("test/data/yml/function/escape.yml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Pref.where(name: "<['北海道', '青森県', '岩手県']>").count
    assert_equal 3, Member.where(name: "F|Pref").count
  end

  # outline: whether 'import methods function' works
  # expected value: registerd escaped str data
  test "import methods" do
    Pokotarou.import("./test/data/methods.rb")
    Pokotarou.execute("test/data/yml/function/import_methods.yml")
    assert_equal true, Pref.where(name: "北海道").present?
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
  end

  # outline: whether 'optimize' works
  # expected value: registerd escaped str data
  test "optimize" do
    Pokotarou.execute("test/data/yml/function/optimize.yml")
    assert_equal true, Pref.where(name: "北海道").present?
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
  end

  # outline: whether pokotarou can register after change parameter
  # expected value: registerd 6 datas
  test "after change parameter" do
    config_data = Pokotarou.get_config("test/data/yml/function/array_insert.yml")
    assert_equal 3, config_data[:Default][:Pref][:loop]
    config_data[:Default][:Pref][:loop] = 6
    Pokotarou.do_seed(config_data)
    assert_equal 6, Pref.all.count
  end

  # outline: whether 'combine_option function' works
  # expected value: registerd 3 datas
  test "combine_option" do
    Pokotarou.execute("test/data/yml/function/combine_option.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道_0").present?
    assert_equal true, Pref.where(name: "北海道_1").present?
    assert_equal true, Pref.where(name: "北海道_2").present?
  end

  # outline: whether 'automatic foreign key' works
  # expected value: registerd 3 datas
  test "automatic foreign_key" do
    Pokotarou.execute("test/data/yml/function/automatic_foreign_key.yml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Member.all.count
    assert_equal Pref.all.pluck(:id), Member.all.pluck(:pref_id)
  end
end