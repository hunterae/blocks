module Blocks
  module HamlHelpers
    def without_haml_interference
      if view.respond_to?(:non_haml)
        view.non_haml { yield }
      else
        yield
      end
    end
  end
end