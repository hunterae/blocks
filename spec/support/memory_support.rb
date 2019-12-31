require 'memory_profiler'

def with_memory_report(&block)
  MemoryProfiler.report(&block)
end

def object_allocations(object_class_or_class = nil, &block)
  report = with_memory_report(&block)
  if object_class_or_class
    report.allocated_objects_by_class.detect {|h| object_class_or_class.to_s == h[:data]}[:count]
  else
    Hash[report.allocated_objects_by_class.map do |o|
      [o[:data].constantize, o[:count]]
    end]
  end
end

