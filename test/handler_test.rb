require 'test_helper'

class Pokotarou::HandlerTest < ActiveSupport::TestCase
  def setup
    # reset import method dataes
    Pokotarou.reset
  end

  # outline: whether 'pokotarou handler delete_block' works
  # expected value: registerd 3 datas
  test "pokotarou handler(delete_block)" do
    handler = Pokotarou.gen_handler("test/data/handler/delete_block.yml")
    handler.delete_block(:Default)
    Pokotarou.execute(handler.get_data())

    assert_equal 3, Pref.all.count
  end

  # outline: whether 'pokotarou handler delete_model works
  # expected value: registerd 3 datas
  #                 registerd ["北海道", "青森県", "岩手県"]
  test "pokotarou handler(delete_model)" do
    handler = Pokotarou.gen_handler("test/data/handler/delete_model.yml")
    handler.delete_model(:Default, :Member)
    Pokotarou.execute(handler.get_data())

    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道").present?
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?

    assert_equal 0, Member.all.count
  end

  # outline: whether 'pokotarou handler delete_col works
  # expected value: registerd 3 datas
  #                 not_registerd ["北海道", "青森県", "岩手県"]
  test "pokotarou handler(delete_col)" do
    handler = Pokotarou.gen_handler("test/data/handler/delete_col.yml")
    handler.delete_col(:Default, :Pref, :name)
    Pokotarou.execute(handler.get_data())

    assert_equal 3, Pref.all.count
    assert_equal true, Pref.find_by(name: "北海道").nil?
    assert_equal true, Pref.find_by(name: "青森県").nil?
    assert_equal true, Pref.find_by(name: "岩手県").nil?
  end

  # outline: whether 'pokotarou handler change_loop' works
  # expected value: registerd 5 datas
  test "pokotarou handler(change_loop)" do
    handler = Pokotarou.gen_handler("test/data/handler/change_loop.yml")
    handler.change_loop(:Default, :Pref, 5)
    Pokotarou.execute(handler.get_data())

    assert_equal 5, Pref.all.count
  end

  # outline: whether 'pokotarou handler change_arr works
  # expected value: registerd 3 datas
  #                 registerd ["茨城県", "栃木県", "沖縄県"]
  test "pokotarou handler(change_arr)" do
    handler = Pokotarou.gen_handler("test/data/handler/change_arr.yml")
    handler.change_seed(:Default, :Pref, :name, ["茨城県", "栃木県", "沖縄県"])
    Pokotarou.execute(handler.get_data())

    assert_equal 3, Pref.all.count
    assert_equal true, Pref.find_by(name: "茨城県").present?
    assert_equal true, Pref.find_by(name: "栃木県").present?
    assert_equal true, Pref.find_by(name: "沖縄県").present?
  end

  # outline: whether 'pokotarou handler chaching function works
  # expected value: registerd 9 datas
  #                 registerd "茨城県" * 3, "栃木県" * 3, "沖縄県" * 3
  test "pokotarou handler(chaching)" do
    arr = [["茨城県"], ["栃木県"], ["沖縄県"]]
    arr.each do |e|
      handler = Pokotarou.gen_handler("test/data/handler/change_arr.yml")
      handler.change_seed(:Default, :Pref, :name, e)
      Pokotarou.execute(handler.get_data())
    end

    assert_equal 9, Pref.all.count
    assert_equal 3, Pref.where(name: "茨城県").count
    assert_equal 3, Pref.where(name: "栃木県").count
    assert_equal 3, Pref.where(name: "沖縄県").count
  end

  # outline: whether 'pokotarou handler with cache works
  # expected value: registerd 9 datas
  test "pokotarou handler(with cache)" do
    handler = Pokotarou.gen_handler_with_cache("test/data/handler/change_arr.yml")
    handler.change_seed(:Default, :Pref, :name, ["茨城県", "栃木県", "沖縄県"])
    Pokotarou.execute(handler.get_data())

    assert_equal 3, Pref.all.count
    assert_equal true, Pref.find_by(name: "茨城県").present?
    assert_equal true, Pref.find_by(name: "栃木県").present?
    assert_equal true, Pref.find_by(name: "沖縄県").present?

    handler = Pokotarou.gen_handler_with_cache("test/data/handler/change_arr.yml")
    handler.change_seed(:Default, :Pref, :name, ["北海道", "青森県", "岩手県"])
    Pokotarou.execute(handler.get_data())
    assert_equal 6, Pref.all.count
    assert_equal true, Pref.find_by(name: "北海道").present?
    assert_equal true, Pref.find_by(name: "青森県").present?
    assert_equal true, Pref.find_by(name: "岩手県").present?

    handler = Pokotarou.gen_handler_with_cache("test/data/handler/change_arr.yml")
    handler.change_seed(:Default, :Pref, :name, ["a", "b", "c"])
    Pokotarou.execute(handler.get_data())
    assert_equal 9, Pref.all.count
    assert_equal true, Pref.find_by(name: "a").present?
    assert_equal true, Pref.find_by(name: "b").present?
    assert_equal true, Pref.find_by(name: "c").present?
  end

  # outline: whether works "set_randomincrement"
  # expected value: registerd 6 datas
  test "should register 6 datas when set randomincrement" do
    handler = Pokotarou.gen_handler("test/data/handler/set_randomincrement.yml")
    handler.set_randomincrement(:Default, :Pref, true)
    handler.make
    assert_equal 3, Pref.all.count

    handler.make
    assert_equal 6, Pref.all.count
  end

  # outline: whether works "set_autoincrement"
  # expected value: registerd 6 datas
  test "should register 6 datas when set autoincrement" do
    handler = Pokotarou.gen_handler("test/data/handler/set_autoincrement.yml")
    handler.set_autoincrement(:Default, :Pref, false)
    
    handler.change_seed(:Default, :Pref, :id, [3, 4, 5])
    handler.make
    assert_equal 3, Pref.all.count
    assert Pref.find(3).present?
    assert Pref.find(4).present?
    assert Pref.find(5).present?

    handler.change_seed(:Default, :Pref, :id, [56, 57, 58])
    handler.make
    assert_equal 6, Pref.all.count
    assert Pref.find(56).present?
    assert Pref.find(57).present?
    assert Pref.find(58).present?
  end
end