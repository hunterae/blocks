module Blocks
  class TableFor < Blocks::Builder
    alias columns block_positions
    alias column use
    
    def header(name, options={}, &block)
      define("#{name.to_s}_header", options, &block)
    end
    
    def initialize(options)
      options[:template] = "blocks/table"
      options[:templates_folder] = "blocks/tables"
      options[:record_variable] = "records"
      options[:variable] = "table"
      super
    end
  end
end
