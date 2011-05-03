module BuildingBlocks
  module HelperMethods
    def blocks
      options = {}
      options[:view] = self
      
      @blocks ||= Base.new(options)
    end
  end
end
