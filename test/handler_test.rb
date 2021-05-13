require 'test_helper'

class Pokotarou::HandlerTest < ActiveSupport::TestCase
  def setup
    # reset import method dataes
    Pokotarou.reset
  end

  # outline: whether 'pokotarou handler delete_block' works
  # expected value: registerd 3 data
  test "pokotarou handler(delete_block)" do
    handler = Pokotarou.gen_handler("test/data/handler/delete_block.yml")
    handler.delete_block(:Default)
    Pokotarou.execute(handler.get_data())

    assert_equal 3, Pref.all.count
  end

  # outline: whether 'pokotarou handler delete_model works
  # expected value: registerd 3 data
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
  # expected value: registerd 3 data
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
  # expected value: registerd 5 data
  test "pokotarou handler(change_loop)" do
    handler = Pokotarou.gen_handler("test/data/handler/change_loop.yml")
    handler.change_loop(:Default, :Pref, 5)
    Pokotarou.execute(handler.get_data())

    assert_equal 5, Pref.all.count
  end

  # outline: whether 'pokotarou handler change_arr works
  # expected value: registerd 3 data
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
  # expected value: registerd 9 data
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
  # expected value: registerd 9 data
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
  # expected value: registerd 6 data
  test "should register 6 data when set randomincrement" do
    handler = Pokotarou.gen_handler("test/data/handler/set_randomincrement.yml")
    handler.set_randomincrement(:Default, :Pref, true)
    handler.make
    assert_equal 3, Pref.all.count

    handler.make
    assert_equal 6, Pref.all.count
  end

  # outline: whether works "set_autoincrement"
  # expected value: registerd 6 data
  test "should register 6 data when set autoincrement" do
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

  # outline: Pokotarou instance からdelete_blockを使った時の挙動を担保する
  # expected value: registerd 3 data
  test "pokotarou handler(delete_block) from Pokotarou instance" do
    Pokotarou::V2.new("test/data/handler/delete_block.yml")
                 .delete_block(:Default)
                 .make

    assert_equal 3, Pref.all.count
  end

  # outline: Pokotarou instance からdelete_modelを使った時の挙動を担保する
  # expected value: registerd 3 data
  #                 registerd ["北海道", "青森県", "岩手県"]
  test "pokotarou handler(delete_model) from Pokotarou instance" do
    Pokotarou::V2.new("test/data/handler/delete_model.yml")
                 .delete_model(:Default, :Member)
                 .make

    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道").present?
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?

    assert_equal 0, Member.all.count
  end

  # outline: Pokotarou instance からdelete_colを使った時の挙動を担保する
  # expected value: registerd 3 data
  #                 not_registerd ["北海道", "青森県", "岩手県"]
  test "pokotarou handler(delete_col) from Pokotarou instance" do
    Pokotarou::V2.new("test/data/handler/delete_col.yml")
                 .delete_col(:Default, :Pref, :name)
                 .make

    assert_equal 3, Pref.all.count
    assert_equal true, Pref.find_by(name: "北海道").nil?
    assert_equal true, Pref.find_by(name: "青森県").nil?
    assert_equal true, Pref.find_by(name: "岩手県").nil?
  end

  # outline: Pokotarou instance からchange_loopを使った時の挙動を担保する
  # expected value: registerd 5 data
  test "pokotarou handler(change_loop) from Pokotarou instance" do
    Pokotarou::V2.new("test/data/handler/change_loop.yml")
                 .change_loop(:Default, :Pref, 5)
                 .make

    assert_equal 5, Pref.all.count
  end

  # outline: Pokotarou instance からchange_seedを使った時の挙動を担保する
  # expected value: registerd 3 data
  #                 registerd ["茨城県", "栃木県", "沖縄県"]
  test "pokotarou handler(change_seed) from Pokotarou instance" do
    Pokotarou::V2.new("test/data/handler/change_arr.yml")
                 .change_seed(:Default, :Pref, :name, ["茨城県", "栃木県", "沖縄県"])
                 .make

    assert_equal 3, Pref.all.count
    assert_equal true, Pref.find_by(name: "茨城県").present?
    assert_equal true, Pref.find_by(name: "栃木県").present?
    assert_equal true, Pref.find_by(name: "沖縄県").present?
  end

  # outline: Pokotarou instance からchachingを使った時の挙動を担保する
  # expected value: registerd 9 data
  #                 registerd "茨城県" * 3, "栃木県" * 3, "沖縄県" * 3
  test "pokotarou handler(chaching) from Pokotarou instance" do
    arr = [["茨城県"], ["栃木県"], ["沖縄県"]]
    arr.each do |e|
      Pokotarou::V2.new("test/data/handler/change_arr.yml")
                   .change_seed(:Default, :Pref, :name, e)
                   .make
    end

    assert_equal 9, Pref.all.count
    assert_equal 3, Pref.where(name: "茨城県").count
    assert_equal 3, Pref.where(name: "栃木県").count
    assert_equal 3, Pref.where(name: "沖縄県").count
  end

  # outline: Pokotarou instance からwith cacheを使った時の挙動を担保する
  # expected value: registerd 9 data
  test "pokotarou handler(with cache) from Pokotarou instance" do

    Pokotarou::V2.new("test/data/handler/change_arr.yml")
                 .change_seed(:Default, :Pref, :name, ["茨城県", "栃木県", "沖縄県"])
                 .make

    assert_equal 3, Pref.all.count
    assert_equal true, Pref.find_by(name: "茨城県").present?
    assert_equal true, Pref.find_by(name: "栃木県").present?
    assert_equal true, Pref.find_by(name: "沖縄県").present?

    Pokotarou::V2.new("test/data/handler/change_arr.yml")
                 .change_seed(:Default, :Pref, :name,  ["北海道", "青森県", "岩手県"])
                 .make

    assert_equal 6, Pref.all.count
    assert_equal true, Pref.find_by(name: "北海道").present?
    assert_equal true, Pref.find_by(name: "青森県").present?
    assert_equal true, Pref.find_by(name: "岩手県").present?

    Pokotarou::V2.new("test/data/handler/change_arr.yml")
                 .change_seed(:Default, :Pref, :name,  ["a", "b", "c"])
                 .make

    assert_equal 9, Pref.all.count
    assert_equal true, Pref.find_by(name: "a").present?
    assert_equal true, Pref.find_by(name: "b").present?
    assert_equal true, Pref.find_by(name: "c").present?
  end

  # outline: Pokotarou instance からset_randomincrementを使った時の挙動を担保する
  # expected value: registerd 6 data
  test "should register 6 data when set randomincrement from Pokotarou instance" do
    pokotarou = Pokotarou::V2.new("test/data/handler/set_randomincrement.yml")
                             .set_randomincrement(:Default, :Pref, true)

    pokotarou.make
    assert_equal 3, Pref.all.count

    pokotarou.make
    assert_equal 6, Pref.all.count
  end

  # outline: Pokotarou instance からset_autoincrementを使った時の挙動を担保する
  # expected value: registerd 6 data
  test "should register 6 data when set autoincrement from Pokotarou instance" do
    pokotarou = Pokotarou::V2.new("test/data/handler/set_autoincrement.yml")
                             .set_autoincrement(:Default, :Pref, false)

    pokotarou.change_seed(:Default, :Pref, :id, [3, 4, 5])
    pokotarou.make

    assert_equal 3, Pref.all.count
    assert Pref.find(3).present?
    assert Pref.find(4).present?
    assert Pref.find(5).present?

    pokotarou.change_seed(:Default, :Pref, :id, [56, 57, 58])
    pokotarou.make

    assert_equal 6, Pref.all.count
    assert Pref.find(56).present?
    assert Pref.find(57).present?
    assert Pref.find(58).present?
  end

  # outline: 複数回の更新をかけた時の挙動を担保する
  # expected value: registerd 5 pref data
  #                 registerd 5 member data
  test "make sure one change loop and multiple change seed" do
    Pokotarou::V2.new("test/data/handler/multiple_update.yml")
                 .change_loop(:Default, :Pref, 5)
                 .change_seed(:Default, :Pref, :name,  ["a", "b", "c"])
                 .change_loop(:Default, :Member, 5)
                 .change_seed(:Default, :Member, :name,  ["A", "B", "C"])
                 .make

    assert_equal 5, Pref.all.count
    assert Pref.find_by(name: "a").present?
    assert Pref.find_by(name: "b").present?
    assert Pref.find_by(name: "c").present?

    assert_equal 5, Member.all.count
    assert Member.find_by(name: "A").present?
    assert Member.find_by(name: "B").present?
    assert Member.find_by(name: "C").present?
  end
end