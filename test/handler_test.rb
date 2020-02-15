require 'test_helper'

class Pokotarou::HandlerTest < ActiveSupport::TestCase
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

  # outline: whether 'pokotarou pipleine_execute with cache works
  # expected value: registerd 9 datas
  test "pokotarou handler(pipleine_execute)" do
    ids = Pokotarou.pipleine_execute([{
      filepath: "test/data/handler/pipeline_execute.yml", 
      change_data: { Default: { Pref: { name: ["a", "b", "c"] } } },
      args: { created_at: DateTime.parse("2018/02/05") },
    },{
      filepath: "test/data/handler/pipeline_execute.yml", 
      change_data: { Default: { Pref: { name:  ["北海道", "青森県", "岩手県"] } } },
      args: { created_at: DateTime.parse("2019/02/05") },
    },{
      filepath: "test/data/handler/pipeline_execute.yml", 
      change_data: { Default: { Pref: { name:  ["茨城県", "栃木県", "沖縄県"] } } },
      args: { created_at: DateTime.parse("2020/02/05") },
    }])

    assert_equal 9, Pref.all.count
    assert_equal true, Pref.find_by(name: "a").present?
    assert_equal true, Pref.find_by(name: "b").present?
    assert_equal true, Pref.find_by(name: "c").present?
    assert_equal true, Pref.find_by(name: "北海道").present?
    assert_equal true, Pref.find_by(name: "青森県").present?
    assert_equal true, Pref.find_by(name: "岩手県").present?
    assert_equal true, Pref.find_by(name: "茨城県").present?
    assert_equal true, Pref.find_by(name: "栃木県").present?
    assert_equal true, Pref.find_by(name: "沖縄県").present?
    assert_equal 3, Pref.where(created_at: DateTime.parse("2018/02/05")).count
    assert_equal 3, Pref.where(created_at: DateTime.parse("2019/02/05")).count
    assert_equal 3, Pref.where(created_at: DateTime.parse("2020/02/05")).count

    assert_equal [[1, 2, 3], [4, 5, 6], [7, 8, 9]], ids
    assert_equal true, Pref.find(1).present?
    assert_equal true, Pref.find(2).present?
    assert_equal true, Pref.find(3).present?
    assert_equal true, Pref.find(4).present?
    assert_equal true, Pref.find(5).present?
    assert_equal true, Pref.find(6).present?
    assert_equal true, Pref.find(7).present?
    assert_equal true, Pref.find(8).present?
    assert_equal true, Pref.find(9).present?
  end

  # outline: whether 'pokotarou pipleine_execute with passed_return_val works
  # expected value: registerd 6 datas
  test "pokotarou handler(pipleine_execute passed_return_val)" do
    values = Pokotarou.pipleine_execute([{
      filepath: "test/data/handler/pipeline_execute_passed_return_val/one.yml", 
      change_data: { Default: { Pref: { name: ["a", "b", "c"] } } },
    },{
      filepath: "test/data/handler/pipeline_execute_passed_return_val/two.yml", 
    }])

    assert_equal 6, Pref.all.count
    assert_equal true, Pref.find_by(name: "a").present?
    assert_equal true, Pref.find_by(name: "b").present?
    assert_equal true, Pref.find_by(name: "c").present?
    assert_equal true, Pref.find_by(name: "hoge").present?
    assert_equal true, Pref.find_by(name: "fuga").present?
    assert_equal true, Pref.find_by(name: "piyo").present?

    assert_equal [["hoge", "fuga", "piyo"], nil], values
  end

  # outline: whether 'pokotarou pipleine_execute with args works
  # expected value: registerd 6 datas
  test "pokotarou handler(pipleine_execute args)" do
    Pokotarou.pipleine_execute([{
      filepath: "test/data/handler/pipeline_execute_with_args.yml", 
      args: { name: ["a", "b", "c"] }
    },{
      filepath: "test/data/handler/pipeline_execute_with_args.yml", 
      args: { name: ["d", "e", "f"] }
    }])

    assert_equal 6, Pref.all.count
    assert_equal true, Pref.find_by(name: "a").present?
    assert_equal true, Pref.find_by(name: "b").present?
    assert_equal true, Pref.find_by(name: "c").present?
    assert_equal true, Pref.find_by(name: "d").present?
    assert_equal true, Pref.find_by(name: "e").present?
    assert_equal true, Pref.find_by(name: "f").present?
  end

  # outline: whether 'pokotarou pipleine_execute with import works
  # expected value: registerd 6 datas
  test "pokotarou handler(pipleine_execute import)" do
    Pokotarou.import("./test/data/methods.rb")
    Pokotarou.pipleine_execute([{
      filepath: "test/data/handler/import/one.yml", 
    },{
      filepath: "test/data/handler/import/two.yml", 
    }])

    assert_equal 6, Pref.all.count
    assert_equal true, Pref.find_by(name: "a").present?
    assert_equal true, Pref.find_by(name: "b").present?
    assert_equal true, Pref.find_by(name: "c").present?
    assert_equal true, Pref.find_by(name: "北海道").present?
    assert_equal true, Pref.find_by(name: "青森県").present?
    assert_equal true, Pref.find_by(name: "岩手県").present?
  end
end