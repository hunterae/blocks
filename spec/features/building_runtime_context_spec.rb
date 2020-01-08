require 'spec_helper'

feature "Building Runtime Context" do
  TEST_BLOCK = :test_block
  PROXY1 = :proxy1
  PROXY2 = :proxy2
  PROXY3 = :proxy3
  RENDER_OPTION = :render
  BUILDER_OPTION = :builder
  GLOBAL_OPTION = :global

  let(:expected_render_item) { "expected" }
  let(:unexpected_render_item) { "unexpected" }
  let(:render_options) { Hash.new }

  def build_runtime_context
    Blocks::RuntimeContext.build(builder, TEST_BLOCK, render_options)
  end

  let(:runtime_context) { build_runtime_context }

  before do
    builder.define PROXY1, with: PROXY2
    builder.define PROXY2, with: PROXY3
  end

  context 'when the render options define the render strategy' do
    before do
      render_options.merge!(with: PROXY1)
      
      # Setup options on various blocks to test the merge order
      render_options.merge!(a: RENDER_OPTION)
      builder.define PROXY1, a: PROXY1, b: PROXY1
      builder.define PROXY2, b: PROXY2, c: PROXY2
      builder.define PROXY3, c: PROXY3, d: PROXY3
      builder.define TEST_BLOCK, d: TEST_BLOCK, e: TEST_BLOCK
      builder.define PROXY1, defaults: { e: PROXY1, f: PROXY1 }
      builder.define PROXY2, defaults: { f: PROXY2, g: PROXY2 }
      builder.define PROXY3, defaults: { g: PROXY3, h: PROXY3 }
      builder.define TEST_BLOCK, defaults: { h: TEST_BLOCK, i: TEST_BLOCK }
      render_options.merge!(defaults: { i: RENDER_OPTION, j: RENDER_OPTION })
      builder.options = { j: BUILDER_OPTION, k: BUILDER_OPTION }
      Blocks.global_options = { k: GLOBAL_OPTION, l: GLOBAL_OPTION }
    end

    it 'should be use precedence rules when merging options' do
      expect(runtime_context).to match(
        a: RENDER_OPTION,
        b: PROXY1,
        c: PROXY2,
        d: PROXY3,
        e: TEST_BLOCK,
        f: PROXY1,
        g: PROXY2,
        h: PROXY3,
        i: TEST_BLOCK,
        j: RENDER_OPTION,
        k: BUILDER_OPTION,
        l: GLOBAL_OPTION
      )
    end

    it 'should be able to configure Blocks to prioritize default render options over all other default options' do
      Blocks.default_render_options_take_precedence_over_block_defaults = true
      render_options[:defaults] = { e: RENDER_OPTION, f: RENDER_OPTION }
      builder.define PROXY1, defaults: { f: PROXY1, g: PROXY1 }
      builder.define PROXY2, defaults: { g: PROXY2, h: PROXY2 }
      builder.define PROXY3, defaults: { h: PROXY3, i: PROXY3 }
      builder.define TEST_BLOCK, defaults: { i: TEST_BLOCK, j: TEST_BLOCK }
      expect(runtime_context).to match(
        a: RENDER_OPTION,
        b: PROXY1,
        c: PROXY2,
        d: PROXY3,
        e: TEST_BLOCK,
        f: RENDER_OPTION,
        g: PROXY1,
        h: PROXY2,
        i: PROXY3,
        j: TEST_BLOCK,
        k: BUILDER_OPTION,
        l: GLOBAL_OPTION
      )
    end

    it 'should resolve a render item at the end of a proxy chain' do
      builder.define PROXY3, defaults: { partial: expected_render_item }
      expect(runtime_context.render_item).to eql expected_render_item
    end

    it 'should not always resolve a render item at the end of a proxy chain, and should ignore render items that are not part of the proxy chain' do
      builder.define PROXY1, defaults: { partial: unexpected_render_item }
      builder.define PROXY2, defaults: { partial: unexpected_render_item }
      builder.define TEST_BLOCK, partial: unexpected_render_item
      render_options[:defaults][:partial] = unexpected_render_item
      builder.options[:partial] = unexpected_render_item
      Blocks.global_options[:partial] = unexpected_render_item
      expect(runtime_context.render_item).to eql nil 
    end

    it 'should not follow any proxy chains except the render options proxy chain' do
      new_proxy = :new_proxy
      render_options[:defaults][:with] = new_proxy
      builder.define new_proxy, new_proxy => new_proxy, partial: unexpected_render_item
      builder.define PROXY1, defaults: { with: new_proxy }
      builder.define PROXY2, defaults: { with: new_proxy }
      builder.define TEST_BLOCK, with: new_proxy
      builder.options[:with] = new_proxy
      Blocks.global_options[:with] = new_proxy
      expect(runtime_context).not_to have_key new_proxy
      expect(runtime_context.render_item).to eql nil
    end
  end

  context 'when the block options define the render strategy' do
    before do
      builder.define TEST_BLOCK, with: PROXY1
      
      # Setup options on various blocks to test the merge order
      render_options.merge!(a: RENDER_OPTION)
      builder.define TEST_BLOCK, a: TEST_BLOCK, b: TEST_BLOCK
      builder.define PROXY1, b: PROXY1, c: PROXY1
      builder.define PROXY2, c: PROXY2, d: PROXY2
      builder.define PROXY3, d: PROXY3, e: PROXY3
      builder.define TEST_BLOCK, defaults: { e: TEST_BLOCK, f: TEST_BLOCK }
      builder.define PROXY1, defaults: { f: PROXY1, g: PROXY1 }
      builder.define PROXY2, defaults: { g: PROXY2, h: PROXY2 }
      builder.define PROXY3, defaults: { h: PROXY3, i: PROXY3 }
      render_options.merge!(defaults: { i: RENDER_OPTION, j: RENDER_OPTION })
      builder.options = { j: BUILDER_OPTION, k: BUILDER_OPTION }
      Blocks.global_options = { k: GLOBAL_OPTION, l: GLOBAL_OPTION }
    end

    it 'should be use precedence rules when merging options' do
      expect(runtime_context).to match(
        a: RENDER_OPTION,
        b: TEST_BLOCK,
        c: PROXY1,
        d: PROXY2,
        e: PROXY3,
        f: TEST_BLOCK,
        g: PROXY1,
        h: PROXY2,
        i: PROXY3,
        j: RENDER_OPTION,
        k: BUILDER_OPTION,
        l: GLOBAL_OPTION
      )
    end

    it 'should be able to configure Blocks to prioritize default render options over all other default options' do
      Blocks.default_render_options_take_precedence_over_block_defaults = true
      render_options[:defaults] = { e: RENDER_OPTION, f: RENDER_OPTION }
      builder.define TEST_BLOCK, defaults: { f: TEST_BLOCK, g: TEST_BLOCK }
      builder.define PROXY1, defaults: { g: PROXY1, h: PROXY1 }
      builder.define PROXY2, defaults: { h: PROXY2, i: PROXY2 }
      builder.define PROXY3, defaults: { i: PROXY3, j: PROXY3 }
      expect(runtime_context).to match(
        a: RENDER_OPTION,
        b: TEST_BLOCK,
        c: PROXY1,
        d: PROXY2,
        e: PROXY3,
        f: RENDER_OPTION,
        g: TEST_BLOCK,
        h: PROXY1,
        i: PROXY2,
        j: PROXY3,
        k: BUILDER_OPTION,
        l: GLOBAL_OPTION
      )
    end

    it 'should resolve a render item at the end of a proxy chain' do
      builder.define PROXY3, defaults: { partial: expected_render_item }
      expect(runtime_context.render_item).to eql expected_render_item
    end

    it 'should not always resolve a render item at the end of a proxy chain, and should ignore render items that are not part of the proxy chain' do
      render_options[:defaults][:partial] = unexpected_render_item
      builder.define TEST_BLOCK, defaults: { partial: unexpected_render_item }
      builder.define PROXY1, defaults: { partial: unexpected_render_item }
      builder.define PROXY2, defaults: { partial: unexpected_render_item }
      builder.options[:partial] = unexpected_render_item
      Blocks.global_options[:partial] = unexpected_render_item
      expect(runtime_context.render_item).to eql nil 
    end

    it 'should not follow any proxy chains except the block proxy chain' do
      new_proxy = :new_proxy
      render_options[:defaults][:with] = new_proxy
      builder.define new_proxy, new_proxy => new_proxy, partial: unexpected_render_item
      builder.define PROXY1, defaults: { with: new_proxy }
      builder.define PROXY2, defaults: { with: new_proxy }
      builder.define TEST_BLOCK, defaults: { with: new_proxy }
      builder.options[:with] = new_proxy
      Blocks.global_options[:with] = new_proxy
      expect(runtime_context).not_to have_key new_proxy
      expect(runtime_context.render_item).to eql nil
    end
  end

  context 'when the default render options define the render strategy' do
    before do
      render_options[:defaults] = { with: PROXY1 }
      
      # Setup options on various blocks to test the merge order
      render_options.merge!(a: RENDER_OPTION)
      builder.define TEST_BLOCK, a: TEST_BLOCK, b: TEST_BLOCK
      builder.define TEST_BLOCK, defaults: { b: TEST_BLOCK, c: TEST_BLOCK }
      render_options[:defaults].merge!(c: RENDER_OPTION, d: RENDER_OPTION)
      builder.define PROXY1, d: PROXY1, e: PROXY1
      builder.define PROXY2, e: PROXY2, f: PROXY2
      builder.define PROXY3, f: PROXY3, g: PROXY3
      builder.define PROXY1, defaults: { g: PROXY1, h: PROXY1 }
      builder.define PROXY2, defaults: { h: PROXY2, i: PROXY2 }
      builder.define PROXY3, defaults: { i: PROXY3, j: PROXY3 }
      builder.options = { j: BUILDER_OPTION, k: BUILDER_OPTION }
      Blocks.global_options = { k: GLOBAL_OPTION, l: GLOBAL_OPTION }
    end

    it 'should be use precedence rules when merging options' do
      expect(runtime_context).to match(
        a: RENDER_OPTION,
        b: TEST_BLOCK,
        c: TEST_BLOCK,
        d: RENDER_OPTION,
        e: PROXY1,
        f: PROXY2,
        g: PROXY3,
        h: PROXY1,
        i: PROXY2,
        j: PROXY3,
        k: BUILDER_OPTION,
        l: GLOBAL_OPTION
      )
    end

    it 'should be able to configure Blocks to prioritize default render options over all other default options' do
      Blocks.default_render_options_take_precedence_over_block_defaults = true

      render_options[:defaults] = { with: PROXY1, b: RENDER_OPTION, c: RENDER_OPTION }
      builder.replace PROXY1, with: PROXY2, c: PROXY1, d: PROXY1 
      builder.replace PROXY2, with: PROXY3, d: PROXY2, e: PROXY2
      builder.replace PROXY3, e: PROXY3, f: PROXY3
      builder.define PROXY1, defaults: { f: PROXY1, g: PROXY1 }
      builder.define PROXY2, defaults: { g: PROXY2, h: PROXY2 }
      builder.define PROXY3, defaults: { h: PROXY3, i: PROXY3 }
      builder.define TEST_BLOCK, defaults: { i: TEST_BLOCK, j: TEST_BLOCK }
      
      expect(runtime_context).to match(
        a: RENDER_OPTION,
        b: TEST_BLOCK,
        c: RENDER_OPTION,
        d: PROXY1,
        e: PROXY2,
        f: PROXY3,
        g: PROXY1,
        h: PROXY2,
        i: PROXY3,
        j: TEST_BLOCK,
        k: BUILDER_OPTION,
        l: GLOBAL_OPTION
      )
    end

    it 'should resolve a render item at the end of a proxy chain' do
      builder.define PROXY3, defaults: { partial: expected_render_item }
      expect(runtime_context.render_item).to eql expected_render_item
    end

    it 'should not always resolve a render item at the end of a proxy chain, and should ignore render items that are not part of the proxy chain' do
      builder.define PROXY1, defaults: { partial: unexpected_render_item }
      builder.define PROXY2, defaults: { partial: unexpected_render_item }
      builder.options[:partial] = unexpected_render_item
      Blocks.global_options[:partial] = unexpected_render_item
      expect(runtime_context.render_item).to eql nil 
    end

    it 'should not follow any proxy chains except the default render options proxy chain' do
      new_proxy = :new_proxy
      builder.define new_proxy, new_proxy => new_proxy, partial: unexpected_render_item
      builder.define PROXY1, defaults: { with: new_proxy }
      builder.define PROXY2, defaults: { with: new_proxy }
      builder.options[:with] = new_proxy
      Blocks.global_options[:with] = new_proxy
      expect(runtime_context).not_to have_key new_proxy
      expect(runtime_context.render_item).to eql nil
    end
  end
end