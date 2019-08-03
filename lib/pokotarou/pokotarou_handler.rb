class PokotarouHandler
  def initialize data
    @data = data
  end

  def delete_model sym_block, sym_class
    @data[sym_block].delete(sym_class)
  end

  def change_loop sym_block, sym_class, n
    @data[sym_block][sym_class][:loop] = n
  end

  def get_data
    @data
  end
end