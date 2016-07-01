module Blocks
  class Renderer
    include ActionView::Helpers::CaptureHelper
    include CallWithParams

    attr_accessor :output_buffer
    attr_accessor :builder

    delegate :view,
             :block_containers,
             :init_options,
             :definition_mode=,
             to: :builder

    def initialize(builder)
      self.builder = builder
    end

    def render(block_name_or_block_container, *args, &block)
      with_output_buffer do
        render_with_hooks(block_name_or_block_container, *args, &block)
      end
    end

    def render_template(template, builder_variable=nil, &block)
      if block_given?
        self.definition_mode = Blocks::Builder::DEFINITION_MODE_TEMPLATE_OVERRIDES
        view.capture(builder, &block)
      end

      self.definition_mode = Blocks::Builder::DEFINITION_MODE_TEMPLATE_DEFAULTS
      locals = Blocks.global_options.merge(init_options).tap do |options|
        variable = builder_variable || options.delete(:builder_variable) || :builder
        options[variable] = builder
      end

      self.definition_mode = Blocks::Builder::DEFINITION_MODE_STANDARD
      view.render(layout: template, locals: locals, &block)
    end

    protected

    def render_with_hooks(block_name_or_block_container, *args, &block)
      runtime_options = args.extract_options!
      options, block_name, block =
        merged_options_and_block_name_and_block_for(block_name_or_block_container, runtime_options, &block)
      wrap_each = options.delete(:wrap_each) || options.delete(:wrap_with) || options.delete(:wrap)
      wrap_all = options.delete(:wrap_all)
      wrap_container_with = options.delete(:wrap_container_with)
      collection = options.delete(:collection)

      render_adjacent_hooks_for("before_all_#{block_name}", *args, runtime_options)
      render_nesting_hooks_for("around_all_#{block_name}", *args, runtime_options) do

        render_wrapper(wrap_all, *args, runtime_options) do
          render_as_collection(collection, *args) do |*item_args|

            render_wrapper(wrap_container_with, *args, runtime_options) do
              render_adjacent_hooks_for("before_#{block_name}", *item_args, runtime_options)
              render_nesting_hooks_for("around_#{block_name}", *item_args, runtime_options) do

                render_wrapper(wrap_each, *item_args, runtime_options) do
                  render_adjacent_hooks_for("prepend_#{block_name}", *item_args, runtime_options)
                  render_block(*item_args, options, &block) if block
                  render_adjacent_hooks_for("append_#{block_name}", *item_args, runtime_options)
                end

              end
              render_adjacent_hooks_for("after_#{block_name}", *item_args, runtime_options)
            end

          end
        end

      end
      render_adjacent_hooks_for("after_all_#{block_name}", *args, runtime_options)
    end

    def render_wrapper(wrapper, *args, &block)
      if wrapper.is_a?(Proc)
        wrapper_block = Proc.new { with_output_buffer { yield } }
        output_buffer << call_with_params(wrapper, wrapper_block, *args)
      else
        yield
      end
    end

    def render_block(*args, &block)
      output_buffer << capture_block(*args, &block)
    end

    def capture_block(*args, &block)
      view.capture(*(args[0, block.arity]), &block)
    end

    def block_container_and_block_name_and_block_for(block_name_or_block_container, &block)
      block_container = if block_name_or_block_container.is_a?(Blocks::Container)
        block_name = block_name_or_block_container.name
        block_name_or_block_container
      else
        block_name = block_name_or_block_container
        block_containers[block_name_or_block_container]
      end

      if block_given?
        [block_container, block_name, block]
      else
        [block_container, block_name, block_container.try(:block)]
      end
    end

    def merged_options_and_block_name_and_block_for(block_name_or_block_container, runtime_options, &block)
      block_container, block_name, block =
        block_container_and_block_name_and_block_for(block_name_or_block_container, &block)

      options = Blocks.global_options.merge(init_options)

      options = options.merge(block_container.default_options) if block_container
      options = options.merge(runtime_options)
      options = options.merge(block_container.runtime_options) if block_container
      [options, block_name, block]
    end

    def render_as_collection(collection, *args, &block)
      if collection
        collection.each do |item|
          yield *([item] + args)
        end
      else
        yield *args
      end
    end

    def render_nesting_hooks_for(wrapper_name, *args, &block)
      around_block_containers = block_containers[wrapper_name].try(:clone) || []
      runtime_options = args.extract_options!

      content_block = Proc.new do
        block_container = around_block_containers.shift
        if block_container
          options, block_name, block =
            merged_options_and_block_name_and_block_for(block_container, runtime_options)
          capture_block(content_block, *args, options, &(block_container.block))
        else
          with_output_buffer { yield }
        end
      end
      output_buffer << content_block.call
    end

    # Utility method to render either the before or after blocks for a partial block
    def render_adjacent_hooks_for(wrapper_name, *args)
      runtime_options = args.extract_options!

      block_containers[wrapper_name].to_a.each do |block_container|
        options, block_name, block =
          merged_options_and_block_name_and_block_for(block_container, runtime_options)
        output_buffer << capture_block(*args, options, &(block_container.block))
      end
    end

    def extract_block_name(block_name_or_block_container)
      if block_name_or_block_container.is_a?(Blocks::Container)
        block_name_or_block_container.name
      else
        block_name_or_block_container
      end
    end
  end
end
