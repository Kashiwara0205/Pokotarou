require 'test_helper'

class Pokotarou::PtoolTest < ActiveSupport::TestCase
  def setup
    # reset import method dataes
    Pokotarou.reset
  end

  # outline: whether 'gen_br_text' works
  # expected value: registerd 3 datas
  test "whether 'gen_br_text method' works" do
    Pokotarou.execute("test/data/p_tool/gen_br_text.yml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Pref.where(name:"text\ntext").count
  end

  # outline: whether 'gen_created_at' works
  # expected value: registerd 3 datas
  test "whether 'gen_created_at method' works" do
    Pokotarou.execute("test/data/p_tool/gen_created_at.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.find_by(created_at: DateTime.parse("1997-02-05")).present?
    assert_equal true, Pref.find_by(created_at: DateTime.parse("1997-02-06")).present?
    assert_equal true, Pref.find_by(created_at: DateTime.parse("1997-02-07")).present?
  end

  # outline: whether 'gen_updated_at' works
  # expected value: registerd 3 datas
  test "whether 'gen_updated_at method' works" do
    Pokotarou.execute("test/data/p_tool/gen_updated_at.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.find_by(updated_at: DateTime.parse("1997-02-05 5:10")).present?
    assert_equal true, Pref.find_by(updated_at: DateTime.parse("1997-02-06 5:10")).present?
    assert_equal true, Pref.find_by(updated_at: DateTime.parse("1997-02-07 5:10")).present?
  end
end