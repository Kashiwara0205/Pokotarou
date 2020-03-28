require 'test_helper'

class Pokotarou::TemplateTest < ActiveSupport::TestCase
  def setup
    # reset import method dataes
    Pokotarou.reset
  end

  # outline: whether template function corretly works
  # expected value: registerd 6 datas
  #                 registerd 3 name datas(["hogeta", "fuga", "pokota"]) from template
  #                 registerd 3 name datas(["hogeta2", "fuga2", "pokota2"])
  test "basic" do
    Pokotarou.execute("test/data/template/basic.yml")
    assert_equal 6, Member.all.count
    assert Member.find_by(name: "hogeta").present?
    assert Member.find_by(name: "fuga").present?
    assert Member.find_by(name: "pokota").present?
    assert Member.find_by(name: "hogeta2").present?
    assert Member.find_by(name: "fuga2").present?
    assert Member.find_by(name: "pokota2").present?

    Pref.all.pluck(:id).each do |e|
      assert_equal 2, Member.where(pref_id: e).count
    end
  end

  # outline: whether template function corretly works in the case of no update
  # expected value: registerd 4 datas
  #                 registerd 4 name datas(["hogeta", "fuga", "pokota", "samurai"])
  test "no update" do
    Pokotarou.execute("test/data/template/no_update.yml")
    assert_equal 4, Member.all.count
    assert Member.find_by(name: "hogeta").present?
    assert Member.find_by(name: "fuga").present?
    assert Member.find_by(name: "pokota").present?
    assert Member.find_by(name: "samurai").present?
  end

  # outline: whether template function corretly works with maked
  # expected value: registerd 3 datas
  #                 registerd 3 name datas(["北海道", "青森県", "岩手県"])
  test "maked" do
    Pokotarou.execute("test/data/template/maked.yml")
    assert_equal 3, Member.all.count
    assert Member.find_by(name: "北海道").present?
    assert Member.find_by(name: "青森県").present?
    assert Member.find_by(name: "岩手県").present?
  end

  # outline: whether template function corretly works with import
  # expected value: registerd 3 datas
  #                 registerd 3 renarks datas(["A", "B", "C"])
  test "import" do
    Pokotarou.import("./test/data/methods.rb")
    Pokotarou.execute("test/data/template/additional_method.yml")
    assert_equal 3, Member.all.count
    assert Member.find_by(name: "北海道").present?
    assert Member.find_by(name: "青森県").present?
    assert Member.find_by(name: "岩手県").present?

    assert Member.find_by(remarks: "A").present?
    assert Member.find_by(remarks: "B").present?
    assert Member.find_by(remarks: "C").present?
  end

  # outline: whether template function corretly works with maked from template
  # expected value: registerd 3 datas
  #                 registerd 3 name datas(["北海道", "青森県", "岩手県"])
  test "maked from template" do
    Pokotarou.execute("test/data/template/maked_from_template.yml")
    assert_equal 3, Member.all.count
    assert Member.find_by(remarks: "北海道").present?
    assert Member.find_by(remarks: "青森県").present?
    assert Member.find_by(remarks: "岩手県").present?
  end
end