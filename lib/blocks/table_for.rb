module Blocks
  class TableFor < Blocks::Context
    alias columns block_positions
    alias column use
    
    def header(name, options={}, &block)
      define("#{name.to_s}_header", options, &block)
    end
    
    def initialize(options)
      options[:template] = "blocks/tables/table"
      options[:templates_folder] = "tables"
      options[:record_variable] = "records"
      options[:variable] = "table"
      super
    end
  end
end
