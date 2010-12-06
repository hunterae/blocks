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