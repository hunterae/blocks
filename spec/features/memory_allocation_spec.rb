require 'spec_helper'

if RUBY_VERSION >= "2.1"
  feature "Memory Allocation" do
    before do
      builder # forces instantiation of builder as we don't want to count that memory allocation in the majority of these test cases
    end

    it 'should allocate limited resources when rendering blocks' do
      expect_object_allocations(Blocks::RuntimeContext => 1) do
        builder.render :some_block
      end

      expect_object_allocations(Blocks::RuntimeContext => 1) do
        builder.render partial: 'my_partial'
      end

      expect_object_allocations(Blocks::RuntimeContext => 1) do
        builder.render partial: 'my_partial', defaults: { a: 1 }
      end

      expect_object_allocations(
        Blocks::RuntimeContext => 1,
        Blocks::BlockDefinition => 2
      ) do
        builder.define :test_block_2, partial: 'my_partial'
        builder.define :test_block, with: :test_block_2
        builder.render :test_block
      end
    end

    it 'should allocate resources defining blocks' do
      # define standard options for :test_block
      expect_object_allocations(Blocks::BlockDefinition => 1) do
        builder.define :test_block, a: 1
      end

      # define default options for :test_block
      expect_object_allocations(Blocks::HashWithRenderStrategy => 1) do
        builder.define :test_block, defaults: { c: 1 }
      end

      # define more standard options on :test_block
      expect_object_allocations do
        builder.define :test_block, with: :d
      end

      # define a new block with no options
      expect_object_allocations(Blocks::BlockDefinition => 1) do
        builder.define :test_block2
      end
    end

    it 'should allocate resources when defining hooks' do
      all_hooks = Blocks::HookDefinition::HOOKS
      expect_object_allocations(
        Blocks::BlockDefinition => 1,
        Blocks::HookDefinition => all_hooks.count
      ) do
        all_hooks.each do |hook|
          builder.send(hook, :test_block)
        end
      end
    end

    it 'should allocate resources when rendering collections' do
      expect_object_allocations(Blocks::RuntimeContext => 1) do
        builder.render collection: [1,2,3,4], partial: 'my_partial'
      end

      expect_object_allocations(
        Blocks::BlockDefinition => 2,
        Blocks::RuntimeContext => 1
      ) do
        builder.define :test_block2, partial: 'my_partial'
        builder.define :test_block, with: :test_block2
        builder.render :test_block, collection: [1,2,3,4]
      end
    end
  end
end