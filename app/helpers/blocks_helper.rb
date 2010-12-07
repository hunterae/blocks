module BlocksHelper

  def table_for(records, options={}, &block)
    options[:view] = self
    options[:records] = records
    options[:block] = block
    options[:row_html] = {:class => lambda { cycle('odd', 'even')}} if options[:row_html].nil?
    
    Blocks::TableFor.new(options).render
  end

  def evaluated_content_options(options={})
    evaluated_options = {}
    options.each_pair { |k, v| evaluated_options[k] = (v.is_a?(Proc) ? v.call : v)}
    evaluated_options
  end

  def request_blocks
    options = {}
    options[:view] = self
    
    @request_blocks ||= Blocks.new(options)
  end
end
