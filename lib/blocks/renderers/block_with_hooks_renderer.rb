# frozen_string_literal: true

module Blocks
  # TODO: Make this render order customizable
  class BlockWithHooksRenderer
    def self.render(runtime_context)
      runtime_context.with_output_buffer do
        if runtime_context.skip_completely
          # noop
        elsif runtime_context.hooks_or_wrappers_present?
          render_hooks(HookDefinition::BEFORE_ALL, runtime_context)
          render_hooks(HookDefinition::AROUND_ALL, runtime_context) do
            WrapperRenderer.render(runtime_context.wrap_all, :wrap_all, runtime_context) do
              CollectionRenderer.render(runtime_context) do |runtime_context|
                WrapperRenderer.render(runtime_context.wrap_each, :wrap_each, runtime_context) do
                  render_hooks(HookDefinition::AROUND, runtime_context) do
                    render_hooks(HookDefinition::BEFORE, runtime_context)
                    if !runtime_context.skip_content
                      WrapperRenderer.render(runtime_context.wrap_with, :wrapper, runtime_context) do
                        render_hooks(HookDefinition::SURROUND, runtime_context) do
                          render_hooks(HookDefinition::PREPEND, runtime_context)
                          BlockRenderer.render(runtime_context)
                          render_hooks(HookDefinition::APPEND, runtime_context)
                        end
                      end
                    end
                    render_hooks(HookDefinition::AFTER, runtime_context)
                  end
                end
              end
            end
          end
          render_hooks(HookDefinition::AFTER_ALL, runtime_context)
        elsif !runtime_context.skip_content
          BlockRenderer.render(runtime_context)
        end
      end
    end

    def self.render_hooks(hook_type, runtime_context, &block)
      renderer_class = block ? NestingBlocksRenderer : AdjacentBlocksRenderer
      renderer_class.render(hook_type, runtime_context, &block)
    end
  end
end