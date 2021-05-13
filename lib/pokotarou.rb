require "activerecord-import"
require "pokotarou/handler_factory"
require "pokotarou/operator"

module Pokotarou
  class V2 
    def initialize filepath
      @handler = Pokotarou::HandlerFactory.gen_handler(filepath)

      return self
    end

    def make
      @handler.make()
    end

    def delete_block sym_block
      @handler.delete_block(sym_block)

      self
    end

    def delete_model sym_block, sym_class
      @handler.delete_model(sym_block, sym_class)

      self
    end

    def delete_col sym_block, sym_class, sym_col
      @handler.delete_col(sym_block, sym_class, sym_col)

      self
    end

    def change_loop sym_block, sym_class, n
      @handler.change_loop(sym_block, sym_class, n)

      self
    end

    def change_seed sym_block, sym_class, sym_col, arr
      @handler.change_seed(sym_block, sym_class, sym_col, arr)

      self
    end

    def get_data
      @handler.get_data
    end

    def set_data data
      @handler.set_data(data)
    end
 
    def set_randomincrement sym_block, sym_class, status
      @handler.set_randomincrement(sym_block, sym_class, status)

      self
    end

    def set_autoincrement sym_block, sym_class, status
      @handler.set_autoincrement(sym_block, sym_class, status)

      self
    end
  end

  # データ作成メソッドはmakeで統一させる
  # executeはレガシー扱いに設定する
  def self.make input
    Operator.execute(input)
  end

  def self.execute input
    Operator.execute(input)
  end

  def self.pipeline_execute input_arr
    Operator.pipeline_execute(input_arr)
  end

  def self.import filepath
    Operator.import(filepath)
  end

  def self.set_args hash
    Operator.set_args(hash)
  end

  def self.reset
    Operator.reset()
  end

  def self.gen_handler filepath
    HandlerFactory.gen_handler(filepath)
  end

  def self.gen_handler_with_cache filepath
    HandlerFactory.gen_handler_with_cache(filepath)
  end

end