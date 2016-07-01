module RSpec
  module Core
    class ExampleGroup
      def let(name, &block)
        if self.respond_to?(name)
          old_method = self.method(name)
          self.class.send(:undef_method, name)
        end
        self.class.send(:define_method, name) do
          if instance_variable_defined?("@#{name}")
            instance_variable_get("@#{name}")
          else
            instance_variable_set("@#{name}", yield)
          end
        end
        self.class.after do
          self.class.send(:undef_method, name)
          self.class.send(:define_method, name, &old_method)
        end
      end
    end
  end
end