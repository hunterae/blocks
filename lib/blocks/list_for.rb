module Blocks
  class ListFor < Blocks::Context
    alias items block_positions
    alias item use
    
    def header(name, options={}, &block)
      define("#{name.to_s}_header", options, &block)
    end
    
    def initialize(options)
      options[:template] = "blocks/list"
      options[:templates_folder] = "blocks/lists"
      options[:record_variable] = "records"
      options[:variable] = "list"
      super
    end
  end
end
