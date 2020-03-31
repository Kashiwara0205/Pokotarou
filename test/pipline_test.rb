require 'test_helper'

class Pokotarou::PiplineTest < ActiveSupport::TestCase  
  def setup
    # reset import method dataes
    Pokotarou.reset
  end

  # outline: whether 'pokotarou pipeline_execute with cache works
  # expected value: registerd 9 datas
  test "pokotarou pipeline_execute" do
    ids = Pokotarou.pipeline_execute([{
      filepath: "test/data/pipeline/pipeline_execute.yml", 
      change_data: { Default: { Pref: { name: ["a", "b", "c"] } } },
      args: { created_at: DateTime.parse("2018/02/05") },
    },{
      filepath: "test/data/pipeline/pipeline_execute.yml", 
      change_data: { Default: { Pref: { name:  ["北海道", "青森県", "岩手県"] } } },
      args: { created_at: DateTime.parse("2019/02/05") },
    },{
      filepath: "test/data/pipeline/pipeline_execute.yml", 
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

  # outline: whether 'pokotarou pipeline_execute with passed_return_val works
  # expected value: registerd 6 datas
  test "pokotarou pipeline_execute passed_return_val" do
    values = Pokotarou.pipeline_execute([{
      filepath: "test/data/pipeline/pipeline_execute_passed_return_val/one.yml", 
      change_data: { Default: { Pref: { name: ["a", "b", "c"] } } },
    },{
      filepath: "test/data/pipeline/pipeline_execute_passed_return_val/two.yml", 
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

  # outline: whether 'pokotarou pipeline_execute with args works
  # expected value: registerd 6 datas
  test "pokotarou pipeline_execute args" do
    Pokotarou.pipeline_execute([{
      filepath: "test/data/pipeline/pipeline_execute_with_args.yml", 
      args: { name: ["a", "b", "c"] }
    },{
      filepath: "test/data/pipeline/pipeline_execute_with_args.yml", 
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

  # outline: whether 'pokotarou pipeline_execute with import works
  # expected value: registerd 6 datas
  test "pokotarou pipeline_execute import" do
    Pokotarou.import("./test/data/methods.rb")
    Pokotarou.pipeline_execute([{
      filepath: "test/data/pipeline/import/one.yml", 
    },{
      filepath: "test/data/pipeline/import/two.yml", 
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