module Blocks
  module DynamicConfiguration
    extend ActiveSupport::Concern

    module ClassMethods
      def add_config(*attrs)
        options = attrs.extract_options!
        instance_reader = options.fetch(:instance_accessor, true) && options.fetch(:instance_reader, true)
        instance_writer = options.fetch(:instance_accessor, true) && options.fetch(:instance_writer, true)
        instance_predicate = options.fetch(:instance_predicate, true)
        default_value = options.fetch(:default, nil)

        attrs.each do |name|
          define_singleton_method(name) do |value="UNDEFINED"|
            if value == "UNDEFINED"
              default_value
            else
              public_send("#{name}=", value)
            end
          end
          define_singleton_method("#{name}?") { !!public_send(name) } if instance_predicate

          ivar = "@#{name}"

          define_singleton_method("#{name}=") do |val|
            singleton_class.class_eval do
              remove_possible_method(name)
              define_method(name) do |value="UNDEFINED"|
                if value == "UNDEFINED"
                  val
                else
                  public_send("#{name}=", value)
                end
              end
            end

            class_eval do
              remove_possible_method(name)
              define_method(name) do
                if instance_variable_defined? ivar
                  instance_variable_get ivar
                else
                  singleton_class.send name
                end
              end
            end
            val
          end

          if instance_reader
            remove_possible_method name
            define_method(name) do
              if instance_variable_defined?(ivar)
                instance_variable_get ivar
              else
                self.class.public_send name
              end
            end
            define_method("#{name}?") { !!public_send(name) } if instance_predicate
          end

          attr_writer name if instance_writer
        end
      end

      def configure
        yield self
      end
    end
  end
end
