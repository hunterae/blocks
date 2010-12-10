module Blocks
  module HelperMethods
    def blocks
      options = {}
      options[:view] = self
      
      @blocks ||= Blocks::Builder.new(options)
    end
    
    def evaluated_content_options(options={}, parameters={})
      evaluated_options = {}
      options.each_pair { |k, v| evaluated_options[k] = (v.is_a?(Proc) ? v.call(parameters) : v)}
      evaluated_options
    end
    
    def table_for(records, options={}, &block)
      options[:view] = self
      options[:records] = records
      options[:block] = block
      options[:row_html] = {:class => lambda { |parameters| cycle('odd', 'even')}} if options[:row_html].nil?
      
      Blocks::TableFor.new(options).render
    end
    
    def list_for(*args, &block)
      options = args.extract_options! 
      
      options[:view] = self
      options[:records] = args.first
      options[:block] = block
      
      Blocks::ListFor.new(options).render
    end
  end
end