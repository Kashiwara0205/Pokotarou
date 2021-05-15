require 'test_helper'
class Pokotarou::ErrorTest < ActiveSupport::TestCase
  # 概要: 存在しないモデルを使用したときのエラーメッセージを担保
  # 期待値: 期待したエラーメッセージの返却
  test "make sure error message when unexists model" do
    puts "=> test用にエラーメッセージが表示されます"
    e = assert_raises Pokotarou::RegistrationConfigMaker::UnexistsModelError do
      Pokotarou.execute("test/data/error/unexists_model.yml")
    end

    assert_equal "Unexists Model Pref2 ", e.message
  end

  # 概要: seedのデータが存在しない時のエラーメッセージを担保
  # 期待値: 期待したエラーメッセージの返却
  test "make sure error message when unexists seed" do
    puts "=> test用にエラーメッセージが表示されます"
    e = assert_raises Pokotarou::RegistrationConfigUpdater::SeedError do
      Pokotarou.execute("test/data/error/unexists_seed.yml")
    end

    assert_equal "Failed generate seed data", e.message
  end

  # 概要: 外部キーのデータが存在しない時のエラーメッセージを担保
  # 期待値: 期待したエラーメッセージの返却
  test "make sure error message when unexists foreign key" do
    puts "=> test用にエラーメッセージが表示されます"
    e = assert_raises Pokotarou::RegistrationConfigUpdater::SeedError do
      Pokotarou.execute("test/data/error/unexists_foreign_key.yml")
    end

    assert_equal "Failed generate seed data", e.message
  end

  # 概要: 存在しないメソッドが使用された時のエラーメッセージを担保
  # 期待値: 期待したエラーメッセージの返却
  test "make sure error message when unexists unexists_method" do
    puts "=> test用にエラーメッセージが表示されます"
    e = assert_raises Pokotarou::RegistrationConfigUpdater::SeedError do
      Pokotarou.execute("test/data/error/unexists_method.yml")
    end

    assert_equal "Failed generate seed data", e.message
  end

  # 概要:モデルの設定がない場合のエラーメッセージを担保
  # 期待値: 期待したエラーメッセージの返却
  test "make sure error message when unxists model config" do
    puts "=> test用にエラーメッセージが表示されます"
    e = assert_raises Pokotarou::RegistrationConfigMaker::UnexistsModelConfigError do
      Pokotarou.execute("test/data/error/unexists_model_config.yml")
    end

    assert_equal "Unexists model config", e.message
  end

  # 概要: 同じブロックが使用されていた時のエラーメッセージを担保する
  # 期待値: 期待したエラーメッセージの返却
  test "make sure error message when use same block name" do
    puts "=> test用にエラーメッセージが表示されます"
    e = assert_raises Pokotarou::RegistrationConfigMaker::PresetError do
      Pokotarou.execute("test/data/error/same_block.yml")
    end

    assert_equal "Block name [ Default ] conflict has occurred", e.message
  end
end