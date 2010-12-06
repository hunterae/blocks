module TablesHelper
  class ::TableFor < Blocks
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

  def table_for(records, options={}, &block)
    options[:view] = self
    options[:records] = records
    options[:block] = block
    options[:row_html] = {:class => lambda { cycle('odd', 'even')}} if options[:row_html].nil?
    
    TableFor.new(options).render
  end
  
end
