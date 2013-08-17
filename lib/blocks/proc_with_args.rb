module Blocks
  class ProcWithArgs
    def self.call(*args)
      return nil unless args.present?
      v = args.shift
      v.is_a?(Proc) ? v.call(*(args[0, v.arity])) : v
    end

    def self.call_each_hash_value(*args)
      options = args.shift.presence || {}
      if options.is_a?(Proc)
        call(options, *args)
      else
        options.inject({}) { |hash, (k, v)| hash[k] = call(v, *args); hash}
      end
    end
  end
end