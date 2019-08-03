class Seeder 
  class << self
    def gen config_data, key
      n = config_data[:loop]
      type = config_data[:type][key]
      enum = config_data[:enum][key]
      foreign_key = config_data[:foreign_key][key]

      return foreign_key.pluck(:id) if foreign_key.present?
      return enum if enum.present?
      return make_array(n, ->(){ rand(100) }) if type == "integer"
      return make_array(n, ->(){ rand(0.0..100.0) }) if type == "float"
      return make_array(n, ->(){ rand(0.0..1_000_000_000.0) }) if type == "decimal"
      return make_array(n, ->(){ SecureRandom.hex(20) }) if type == "string"
      return make_array(n, ->(){ SecureRandom.hex(300) }) if ["text", "binary"].include?(type)
      return make_array(n, ->(){ [1, 0].sample }) if type == "boolean"
      return make_string_array(n, enum) if type == "string"
      return make_datetime_array() if ["string", "datetime", "date", "time"].include?(type)
    end

    private

    def make_array n, proc
      Array.new(n).map{ proc.call() }
    end

    def make_datetime_array
      [Time.now.to_s(:db)]
    end
  end
end