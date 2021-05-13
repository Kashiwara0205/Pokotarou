module Pokotarou

  class Handler
    def initialize data
      @data = data
    end

    def make
      data = get_data()

      AdditionalMethods::Main.init()
  
      # if input is filepath, generate config_data
      return_val =
        if data.kind_of?(String)
          SeedDataRegister::Main.register(gen_config(data))
        else
          SeedDataRegister::Main.register(data)
        end

      AdditionalMethods::Main.remove_filepathes_from_yml()

      return_val
    end

    def delete_block sym_block
      @data.delete(sym_block)
    end

    def delete_model sym_block, sym_class
      @data[sym_block].delete(sym_class)
    end

    def delete_col sym_block, sym_class, sym_col
      exists_content = ->(key){ @data[sym_block][sym_class][key].present? }

      @data[sym_block][sym_class][:col].delete(sym_col) if exists_content.call(:col)
      @data[sym_block][sym_class][:option].delete(sym_col) if exists_content.call(:option)
      @data[sym_block][sym_class][:convert].delete(sym_col) if exists_content.call(:convert)
    end

    def change_loop sym_block, sym_class, n
      @data[sym_block][sym_class][:loop] = n
    end

    def change_seed sym_block, sym_class, sym_col, arr
      @data[sym_block][sym_class][:col][sym_col] = arr
    end

    def get_data
      @data.deep_dup
    end

    def set_data data
      @data = data
    end
 
    def set_randomincrement sym_block, sym_class, status
      @data[sym_block][sym_class][:randomincrement] = status
    end

    def set_autoincrement sym_block, sym_class, status
      @data[sym_block][sym_class][:autoincrement] = status
    end
  end
end