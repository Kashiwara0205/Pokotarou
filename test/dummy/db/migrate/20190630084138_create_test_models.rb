class CreateTestModels < ActiveRecord::Migration[5.1]
  def change
    create_table :test_models do |t|
      t.string :string_test
      t.text :text_test
      t.integer :integer_test
      t.float :float_test
      t.decimal :decimal_test
      t.datetime :datetime_test
      t.timestamp :timestamp_test
      t.time :time_test
      t.date :date_test
      t.binary :binary_test
      t.boolean :boolean_test

      t.timestamps
    end
    
    execute <<-SQL
      ALTER TABLE `test_models` ADD enum_test ENUM('enum1', 'enum2', 'enum3') NOT NULL;
    SQL
  end

end
