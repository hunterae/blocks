module Blocks
  class ListFor < Blocks::Context
    alias items block_positions
    alias item use
    
    def initialize(options)
      options[:template] = "blocks/list"
      options[:templates_folder] = "blocks/lists"
      options[:record_variable] = "records"
      options[:variable] = "list"
      super
    end
  end
end
