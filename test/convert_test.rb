require 'test_helper'
class Pokotarou::ConvertTest < ActiveSupport::TestCase
  def setup
    # reset import method dataes
    Pokotarou.reset
  end

  # outline: whether 'convert empty[0..2]' works 
  # expected value: registerd 3 datas
  #                 registerd ["", "", ""]
  test "convert empty(all)" do
    Pokotarou.execute("test/data/convert/empty/all_empty.yml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Pref.where(name: "").count
  end

  # outline: whether 'convert empty[0..2]' works when nothing col
  # expected value: registerd 3 datas
  #                 registerd ["", "", ""]
  test "convert empty(nothing_col)" do
    Pokotarou.execute("test/data/convert/empty/nothing_col.yml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Pref.where(name: "").count
  end

  # outline: whether 'convert empty[0..0]' works 
  # expected value: registerd 3 datas
  #                 registerd ["", "青森県", "岩手県"]
  test "convert empty(one)" do
    Pokotarou.execute("test/data/convert/empty/one_empty.yml")
    assert_equal 3, Pref.all.count
    assert_equal 1, Pref.where(name: "").count
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
  end

  # outline: whether 'convert nil[0..2]' works 
  # expected value: registerd 3 datas
  #                 registerd [nil, nil, nil]
  test "convert nil(all)" do
    Pokotarou.execute("test/data/convert/nil/all_nil.yml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Pref.where(name: nil).count
  end

  # outline: whether 'convert nil[0..2]' works when nothing col
  # expected value: registerd 3 datas
  #                 registerd [nil, nil, nil]
  test "convert nil(nothing_col)" do
    Pokotarou.execute("test/data/convert/nil/nothing_col.yml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Pref.where(name: nil).count
  end

  # outline: whether 'convert nil[0..0]' works 
  # expected value: registerd 3 datas
  #                 registerd [nil, "青森県", "岩手県"]
  test "convert nil(one)" do
    Pokotarou.execute("test/data/convert/nil/one_nil.yml")
    assert_equal 3, Pref.all.count
    assert_equal 1, Pref.where(name: nil).count
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
  end
  
  # outline: whether 'convert br_text[0..2]' works 
  # expected value: registerd 3 datas
  #                 registerd ["text\n"*5, "text\n"*5, "text\n"*5]
  test "convert br_text(all)" do
    Pokotarou.execute("test/data/convert/br_text/all_br_text.yml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Pref.where(name: "text\n"*5).count
  end

  # outline: whether 'convert br_text[0..2]' works when nothing col
  # expected value: registerd 3 datas
  #                 registerd ["text\n"*5, "text\n"*5, "text\n"*5]
  test "convert br_text(nothing_col)" do
    Pokotarou.execute("test/data/convert/br_text/nothing_col.yml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Pref.where(name: "text\n"*5).count
  end

  # outline: whether 'convert br_text[0..0]' works 
  # expected value: registerd 3 datas
  #                 registerd ["text\n"*5, "青森県", "岩手県"]
  test "convert br_text(one)" do
    Pokotarou.execute("test/data/convert/br_text/one_br_text.yml")
    assert_equal 3, Pref.all.count
    assert_equal 1, Pref.where(name: "text\n"*5).count
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
  end

  # outline: whether 'convert big_text[0..2]' works 
  # expected value: registerd 3 datas
  #                 registerd ["text"*50, "text"*50, "text"*50]
  test "convert big_text(all)" do
    Pokotarou.execute("test/data/convert/big_text/all_big_text.yml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Pref.where(name: "text"*50).count
  end

  # outline: whether 'convert big_text[0..2]' works when nothing col
  # expected value: registerd 3 datas
  #                 registerd ["text"*50, "text"*50, "text"*50]
  test "convert big_text(nothing_col)" do
    Pokotarou.execute("test/data/convert/big_text/nothing_col.yml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Pref.where(name: "text"*50).count
  end

  # outline: whether 'convert big_text[0..0]' works 
  # expected value: registerd 3 datas
  #                 registerd ["text"*50, "青森県", "岩手県"]
  test "convert big_text(one)" do
    Pokotarou.execute("test/data/convert/big_text/one_big_text.yml")
    assert_equal 3, Pref.all.count
    assert_equal 1, Pref.where(name: "text"*50).count
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
  end

  # outline: whether 'convert complex_val' works 
  # expected value: registerd 3 datas
  #                 registerd [nil, "", ""]
  test "convert complex_val(empty_and_nil)" do
    Pokotarou.execute("test/data/convert/complex.yml")
    assert_equal 3, Pref.all.count
    assert_equal 1, Pref.where(name: "").count
    assert_equal true, Pref.where(name: nil).present?
    assert_equal true, Pref.where(name: nil).present?
  end

  # outline: whether 'convert complex_val' works when nothing col
  # expected value: registerd 3 datas
  #                 registerd [nil, "", ""]
  test "convert complex_val(nothing_col)" do
    Pokotarou.execute("test/data/convert/nothing_col.yml")
    assert_equal 3, Pref.all.count
    assert_equal 1, Pref.where(name: "").count
    assert_equal true, Pref.where(name: nil).present?
    assert_equal true, Pref.where(name: nil).present?
  end
end