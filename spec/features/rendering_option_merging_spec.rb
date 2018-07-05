require 'spec_helper'

feature "Rendering Option Merging" do
  TEST_BLOCK = :test_block

  let(:runtime_context) { Blocks::RuntimeContext.build(builder, TEST_BLOCK) }

  it 'should merge and give precedence to render options over block runtime options' do
    builder.define TEST_BLOCK, runtime: { shared: 1, a: 1 }
    runtime_context = Blocks::RuntimeContext.build builder, TEST_BLOCK, shared: 2, b: 2
    expect(runtime_context).to eql({ shared: 2, a: 1, b: 2 })
  end

  it 'should merge and give precedence to block runtime options over builder runtime options' do
    builder = Blocks::Builder.new(view, runtime: { shared: 1, a: 1 })
    builder.define TEST_BLOCK, runtime: { shared: 2, b: 2 }
    runtime_context = Blocks::RuntimeContext.build builder, TEST_BLOCK
    expect(runtime_context).to eql({ shared: 2, a: 1, b: 2 })
  end

  it 'should merge and give precedence to builder runtime options over global runtime options' do
    Blocks.global_options_set.add_options runtime: { shared: 1, a: 1 }
    builder = Blocks::Builder.new(view, runtime: { shared: 2, b: 2 })
    runtime_context = Blocks::RuntimeContext.build builder, TEST_BLOCK
    expect(runtime_context).to eql({ shared: 2, a: 1, b: 2 })
  end

  it 'should merge and give precedence to global runtime options over standard block options' do
    Blocks.global_options_set.add_options runtime: { shared: 1, a: 1 }
    builder.define TEST_BLOCK, shared: 2, b: 2
    expect(runtime_context).to eql({ shared: 1, a: 1, b: 2 })
  end

  it 'should merge and give precedence to block standard options over builder standard options' do
    builder = Blocks::Builder.new(view, shared: 1, a: 1)
    builder.define TEST_BLOCK, shared: 2, b: 2
    runtime_context = Blocks::RuntimeContext.build builder, TEST_BLOCK
    expect(runtime_context).to eql({ shared: 2, a: 1, b: 2 })
  end

  it 'should merge and give precedence to builder standard options over global standard options' do
    Blocks.global_options_set.add_options shared: 1, a: 1
    builder = Blocks::Builder.new(view, shared: 2, b: 2)
    runtime_context = Blocks::RuntimeContext.build builder, TEST_BLOCK
    expect(runtime_context).to eql({ shared: 2, a: 1, b: 2 })
  end

  it 'should merge and give precedence to global standard options over render default options' do
    Blocks.global_options_set.add_options shared: 1, a: 1
    runtime_context = Blocks::RuntimeContext.build builder, TEST_BLOCK, defaults: { shared: 2, b: 2}
    expect(runtime_context).to eql({ shared: 1, a: 1, b: 2 })
  end

  it 'should merge and give precedence to render default options over block default options' do
    builder.define TEST_BLOCK, defaults: { shared: 1, a: 1 }
    runtime_context = Blocks::RuntimeContext.build builder, TEST_BLOCK, defaults: { shared: 2, b: 2}
    expect(runtime_context).to eql({ shared: 2, a: 1, b: 2 })
  end

  it 'should merge and give precedence to block default options over builder default options' do
    builder = Blocks::Builder.new(view, defaults: { shared: 1, a: 1 })
    builder.define TEST_BLOCK, defaults: { shared: 2, b: 2 }
    runtime_context = Blocks::RuntimeContext.build builder, TEST_BLOCK
    expect(runtime_context).to eql({ shared: 2, a: 1, b: 2 })
  end

  it 'should merge and give precedence to builder default options over global default options' do
    Blocks.global_options_set.add_options defaults: { shared: 1, a: 1 }
    builder = Blocks::Builder.new(view, defaults: { shared: 2, b: 2 })
    runtime_context = Blocks::RuntimeContext.build builder, TEST_BLOCK
    expect(runtime_context).to eql({ shared: 2, a: 1, b: 2 })
  end

  it 'should obey the merging and precedence rules for an example that includes every type of option' do
    Blocks.global_options_set.add_options runtime: {
      shared: 1, a: 1, run: 1
    }, shared: 2, b: 2, std: 1, defaults: {
      shared: 3, c: 3 , def: 1
    }

    builder = Blocks::Builder.new(view,
      runtime: { shared: 4, d: 4, run: 2 },
      shared: 5, e: 5, std: 2,
      defaults: { shared: 6, f: 6, def: 2 })

    builder.define TEST_BLOCK, runtime: {
      shared: 7, g: 7, run: 3
    },
    shared: 8, h: 8, std: 3,
    defaults: {
      shared: 9, i: 9, def: 3
    }

    runtime_context = Blocks::RuntimeContext.build builder, TEST_BLOCK,
      shared: 10, j: 10, run: 4, defaults: {
        shared: 11, k: 11, def: 4
      }

    expect(runtime_context).to eql({
      shared: 10, run: 4, def: 4, std: 3,
      a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11
    })
  end
end