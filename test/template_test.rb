require 'test_helper'

class Pokotarou::TemplateTest < ActiveSupport::TestCase

  # outline: whether return function corretly works
  # expected value: registerd 6 datas
  #                 registerd 3 name datas(["hogeta", "fuga", "pokota"]) from template
  #                 registerd 3 name datas(["hogeta2", "fuga2", "pokota2"])
  test "template" do
    Pokotarou.execute("test/data/template/template.yml")
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
end