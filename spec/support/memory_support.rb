if RUBY_VERSION >= "2.1"
  require 'memory_profiler'

  DEFAULT_ALLOCATIONS = {
    Blocks::RuntimeContext => 0,
    Blocks::OptionsSet => 0,
    Blocks::HashWithRenderStrategy => 0,
    Blocks::BlockDefinition => 0,
    Blocks::HookDefinition => 0,
    HashWithIndifferentAccess => 0
  }

  def with_memory_report(&block)
    MemoryProfiler.report(&block)
  end

  def object_allocations(object_class_or_class = nil, &block)
    report = with_memory_report(&block)
    if object_class_or_class
      report.allocated_objects_by_class.detect {|h| object_class_or_class.to_s == h[:data]}[:count]
    else
      Hash[report.allocated_objects_by_class.map do |o|
        [o[:data], o[:count]]
      end]
    end
  end

  def expect_object_allocations(allocation_counts={}, &block)
    allocation_counts.reverse_merge! DEFAULT_ALLOCATIONS
    allocations = object_allocations &block
    allocation_counts.each do |klass, value|
      count = allocations[klass.name]
      expect(count.to_i).to eql(value.to_i), "#{klass} should have been allocated #{value.to_i} time(s), was allocated #{count.to_i} time(s)"
    end
  end
end
