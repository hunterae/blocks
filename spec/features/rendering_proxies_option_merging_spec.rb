require 'spec_helper'

feature "Rendering Proxies Option Merging" do
  let(:block_name) { :test_block }
  let(:proxy_block_1_name) { :proxy_block_1 }
  let(:proxy_block_2_name) { :proxy_block_2 }
  let(:proxy_block_3_name) { :proxy_block_3 }
  let(:proxy_block_4_name) { :proxy_block_4 }

  let(:builder) { Blocks::Builder.new(view, builder_options) }
  let(:runtime_context) { Blocks::RuntimeContext.build(builder, block_name, render_options) }

  let(:render_options) { {} }
  let(:builder_options) { {} }
  let(:global_options) { {} }
  let(:block_options) { {} }

  let(:expected_partial) { "expected" }
  let(:unexpected_partial) { "unexpected" }

  [:runtime, :defaults].each do |option_level|
    context "when render options specify a proxy at the #{option_level} level" do
      let(:base_options) do
        if option_level == :runtime
          { with: proxy_block_1_name }
        else
          { defaults: { with: proxy_block_1_name } }
        end
      end
      let(:render_options) { base_options }

      it "should merge and give precedence to the render options over the proxy runtime options" do
        render_options =  base_options.deep_merge(shared: 1, run: 1, a: 1, defaults: { b: 2, c: 3, def: 1 })

        builder.define proxy_block_1_name, runtime: { shared: 4, d: 4, run: 2 }, with: proxy_block_2_name, shared: 5, e: 5, std: 2, defaults: { shared: 6, f: 6, def: 2 }
        builder.define proxy_block_2_name, runtime: { shared: 6, g: 7, run: 3 }, with: proxy_block_3_name, shared: 7, h: 8, std: 3, defaults: { shared: 8, i: 9, def: 3 }
        builder.define proxy_block_3_name, runtime: { shared: 9, j: 10, run: 4 }, shared: 10, k: 11, std: 4, defaults: { shared: 11, l: 12, def: 4 }
        expect(Blocks::RuntimeContext.build(builder, block_name, render_options)).to eql({ shared: 1, run: 1, std: 2, def: 1, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11, l: 12 })
      end

      it "should merge and give precedence to the proxy options over the block options" do
        builder.define block_name, runtime: { shared: 1, a: 1, run: 1 }, shared: 2, b: 2, std: 1, defaults: { shared: 3, c: 3, def: 1 }
        builder.define proxy_block_1_name, runtime: { shared: 4, d: 4, run: 2 }, with: proxy_block_2_name, shared: 5, e: 5, std: 2, defaults: { shared: 6, f: 6, def: 2 }
        builder.define proxy_block_2_name, runtime: { shared: 6, g: 7, run: 3 }, with: proxy_block_3_name, shared: 7, h: 8, std: 3, defaults: { shared: 8, i: 9, def: 3 }
        builder.define proxy_block_3_name, runtime: { shared: 9, j: 10, run: 4 }, shared: 10, k: 11, std: 4, defaults: { shared: 11, l: 12, def: 4 }
        expect(runtime_context).to eql({ shared: 4, run: 2, std: 2, def: 2, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11, l: 12 })
      end

      it "should give precedence to the proxy render item over the block render item" do
        builder.define block_name, option_level => { partial: unexpected_partial } # ignored
        builder.define proxy_block_1_name, with: proxy_block_2_name
        builder.define proxy_block_2_name, with: proxy_block_3_name
        builder.define proxy_block_3_name, option_level => { partial: expected_partial }
        expect(runtime_context.render_item).to eql expected_partial
      end
    end
  end

  context "when block options specify a proxy" do
    [:runtime, :standard, :defaults].each do |option_level|
      context "at the #{option_level} level" do
        let(:block_options) do
          if option_level == :runtime
            { runtime: { with: proxy_block_1_name } }
          elsif option_level == :standard
            { with: proxy_block_1_name }
          else
            { defaults: { with: proxy_block_1_name } }
          end
        end

        it "should merge and give precedence to the block options over the proxy options" do
          builder.define block_name, block_options.deep_merge(runtime: { shared: 1, a: 1, run: 1 }, shared: 2, b: 2, std: 1, defaults: { shared: 3, c: 3, def: 1 })
          builder.define proxy_block_1_name, runtime: { shared: 4, d: 4, run: 2 }, with: proxy_block_2_name, shared: 5, e: 5, std: 2, defaults: { shared: 6, f: 6, def: 2 }
          builder.define proxy_block_2_name, runtime: { shared: 6, g: 7, run: 3 }, with: proxy_block_3_name, shared: 7, h: 8, std: 3, defaults: { shared: 8, i: 9, def: 3 }
          builder.define proxy_block_3_name, runtime: { shared: 9, j: 10, run: 4 }, shared: 10, k: 11, std: 4, defaults: { shared: 11, l: 12, def: 4 }
          expect(runtime_context).to eql({ shared: 1, run: 1, std: 1, def: 1, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11, l: 12 })
        end

        it "should merge and give precedence to the proxy options over the builder options" do
          let(:builder_options) { { runtime: { shared: 1, a: 1, run: 1 }, shared: 2, b: 2, std: 1, defaults: { shared: 3, c: 3, def: 1 } }}
          builder.define block_name, block_options
          builder.define proxy_block_1_name, runtime: { shared: 4, d: 4, run: 2 }, with: proxy_block_2_name, shared: 5, e: 5, std: 2, defaults: { shared: 6, f: 6, def: 2 }
          builder.define proxy_block_2_name, runtime: { shared: 6, g: 7, run: 3 }, with: proxy_block_3_name, shared: 7, h: 8, std: 3, defaults: { shared: 8, i: 9, def: 3 }
          builder.define proxy_block_3_name, runtime: { shared: 9, j: 10, run: 4 }, shared: 10, k: 11, std: 4, defaults: { shared: 11, l: 12, def: 4 }
          expect(runtime_context).to eql({ shared: 4, run: 2, std: 2, def: 2, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11, l: 12 })
        end

        it "should give precedence to the proxy render item over the builder render item" do
          if option_level == :standard
            builder.options_set.add_options partial: unexpected_partial
          else
            builder.options_set.add_options option_level => { partial: unexpected_partial }
          end
          builder.define block_name, block_options
          builder.define proxy_block_1_name, with: proxy_block_2_name
          builder.define proxy_block_2_name, with: proxy_block_3_name
          if option_level == :standard
            builder.define proxy_block_3_name, partial: expected_partial
          else
            builder.define proxy_block_3_name, option_level => { partial: expected_partial }
          end

          expect(runtime_context.render_item).to eql expected_partial
        end
      end
    end
  end

  context "when builder options specify a proxy" do
    [:runtime, :standard, :defaults].each do |option_level|
      context "at the #{option_level} level" do
        let(:builder_options) do
          if option_level == :runtime
            { runtime: { with: proxy_block_1_name } }
          elsif option_level == :standard
            { with: proxy_block_1_name }
          else
            { defaults: { with: proxy_block_1_name } }
          end
        end

        it "should merge and give precedence to the builder options over the proxy options" do
          builder = Blocks::Builder.new(view, builder_options.deep_merge(runtime: { shared: 1, a: 1, run: 1 }, shared: 2, b: 2, std: 1, defaults: { shared: 3, c: 3, def: 1 }))
          builder.define proxy_block_1_name, runtime: { shared: 4, d: 4, run: 2 }, with: proxy_block_2_name, shared: 5, e: 5, std: 2, defaults: { shared: 6, f: 6, def: 2 }
          builder.define proxy_block_2_name, runtime: { shared: 6, g: 7, run: 3 }, with: proxy_block_3_name, shared: 7, h: 8, std: 3, defaults: { shared: 8, i: 9, def: 3 }
          builder.define proxy_block_3_name, runtime: { shared: 9, j: 10, run: 4 }, shared: 10, k: 11, std: 4, defaults: { shared: 11, l: 12, def: 4 }
          runtime_context = Blocks::RuntimeContext.build(builder, block_name)
          expect(runtime_context).to eql({ shared: 1, run: 1, std: 1, def: 1, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11, l: 12 })
        end

        it "should merge and give precedence to the proxy options over the global options" do
          Blocks.global_options_set.add_options runtime: { shared: 1, a: 1, run: 1 }, shared: 2, b: 2, std: 1, defaults: { shared: 3, c: 3, def: 1 }
          builder.define proxy_block_1_name, runtime: { shared: 4, d: 4, run: 2 }, with: proxy_block_2_name, shared: 5, e: 5, std: 2, defaults: { shared: 6, f: 6, def: 2 }
          builder.define proxy_block_2_name, runtime: { shared: 6, g: 7, run: 3 }, with: proxy_block_3_name, shared: 7, h: 8, std: 3, defaults: { shared: 8, i: 9, def: 3 }
          builder.define proxy_block_3_name, runtime: { shared: 9, j: 10, run: 4 }, shared: 10, k: 11, std: 4, defaults: { shared: 11, l: 12, def: 4 }
          expect(runtime_context).to eql({ shared: 4, run: 2, std: 2, def: 2, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11, l: 12 })
        end

        it "should give precedence to the proxy render item over the global render item" do
          global_options = if option_level == :standard
            { partial: unexpected_partial }
          else
            { option_level => { partial: unexpected_partial }}
          end
          Blocks.global_options_set.add_options global_options
          builder.define proxy_block_1_name, with: proxy_block_2_name
          builder.define proxy_block_2_name, with: proxy_block_3_name
          proxy_options = if option_level == :standard
            { partial: expected_partial }
          else
            { option_level => { partial: expected_partial }}
          end
          builder.define proxy_block_3_name, proxy_options
          expect(runtime_context.render_item).to eql expected_partial
        end
      end
    end
  end

  context "when global options specify a proxy" do
    [:runtime, :standard, :default].each do |option_level|
      let(:global_options) do
        if option_level == :runtime
          { runtime: { with: proxy_block_1_name } }
        elsif option_level == :standard
          { with: proxy_block_1_name }
        else
          { defaults: { with: proxy_block_1_name } }
        end
      end

      context "at the #{option_level} level" do
        it "should merge and give precedence to the global options options over the proxy options" do
          Blocks.global_options_set.add_options(global_options.deep_merge(runtime: { shared: 1, a: 1, run: 1 }, shared: 2, b: 2, std: 1, defaults: { shared: 3, c: 3, def: 1 }))
          builder.define proxy_block_1_name, runtime: { shared: 4, d: 4, run: 2 }, with: proxy_block_2_name, shared: 5, e: 5, std: 2, defaults: { shared: 6, f: 6, def: 2 }
          builder.define proxy_block_2_name, runtime: { shared: 6, g: 7, run: 3 }, with: proxy_block_3_name, shared: 7, h: 8, std: 3, defaults: { shared: 8, i: 9, def: 3 }
          builder.define proxy_block_3_name, runtime: { shared: 9, j: 10, run: 4 }, shared: 10, k: 11, std: 4, defaults: { shared: 11, l: 12, def: 4 }
          runtime_context = Blocks::RuntimeContext.build(builder)
          expect(runtime_context).to eql({ shared: 1, run: 1, std: 1, def: 1, a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11, l: 12 })
        end
      end
    end
  end

  it "should always proxy through the highest precedence level" do
    builder.define block_name, runtime: { with: proxy_block_1_name }, with: :a, defaults: { with: :b }
    builder.define proxy_block_1_name, runtime: { with: proxy_block_2_name }, with: :c, defaults: { with: :d }
    builder.define proxy_block_2_name, with: proxy_block_3_name, defaults: { with: :d }
    builder.define proxy_block_3_name, defaults: { with: proxy_block_4_name}
    builder.define proxy_block_4_name, partial: "hello_world"
    expect(runtime_context.render_item).to eql "hello_world"
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

    builder.define block_name, runtime: {
      shared: 7, g: 7, run: 3
    },
    shared: 8, h: 8, std: 3,
    defaults: {
      shared: 9, i: 9, def: 3
    },
    with: :proxy_block_1

    builder.define :proxy_block_1, runtime: {
      shared: 10, j: 10, run: 4
    },
    shared: 11, k: 11, std: 4,
    defaults: {
      shared: 12, l: 12, def: 4
    },
    with: :proxy_block_2

    builder.define :proxy_block_2, runtime: {
      shared: 13, m: 13, run: 5
    },
    shared: 14, n: 14, std: 5,
    defaults: {
      shared: 15, o: 15, def: 5
    }

    runtime_context = Blocks::RuntimeContext.build builder, block_name,
      shared: 16, p: 16, run: 6, defaults: {
        shared: 17, q: 17, def: 6
      }

    expect(runtime_context).to eql({
      shared: 16, run: 6, def: 6, std: 3,
      a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11,
      l: 12, m: 13, n: 14, o: 15, p: 16, q: 17
    })
  end
end