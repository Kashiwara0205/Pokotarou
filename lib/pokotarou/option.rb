class Option
  class << self
    def gen option
      # shape option data
      # [option1, option2] => { select: [option2], add: [option1] }
      # [] => { select: [], add: [] }
      option.nil? ? { select: [], add: [] } : separate(option)
    end

    def apply arr, size, option_conf, cnt = 0
      selected_val = select(option_conf[:select], arr, size, cnt)
      add(option_conf[:add], selected_val, cnt)
    end

    private

    def separate option
      # separate option to 'select' and 'add'
      # { select = >[], add => [] }
      select_filter = ->(name){ ["rotate", "random"].include?(name) }
      add_filter = ->(name){ ["add_id"].include?(name) }

      {
        select: option.find{|s| select_filter.call(s)},
        add: option.find{|s| add_filter.call(s)}
      }
    end

    def select option, arr, size, cnt
      return arr.sample if option == "random"
      # default return rotate
      get_rotated_val(arr, size, cnt)
    end

    def add option, val, cnt
      # use '+', not use '<<' to avoid destructive effect
      return val + "_#{cnt}" if option == "add_id"

      val
    end
  end
end