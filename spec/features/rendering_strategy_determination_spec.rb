require 'spec_helper'

# The purpose of this spec is to test the logic surrounding determination
#  of the render item for rendering a block. This is determined by a
#  complex set of logic that takes into consideration default options,
#  runtime options, standard options, render options, and different
#  rendering strategies such as rendering with a partial, a block, a
#  proxy to another block, or a default rendering block.
feature "Rendering Strategy Determination" do
  TEST_BLOCK = :test_block

  let(:builder) { Blocks::Builder.new(view) }
  let(:runtime_context) { Blocks::RuntimeContext.new(builder, TEST_BLOCK) }

  describe "when there are only default options set" do
    context "when there is a global default render strategy provided" do
      before do
        Blocks.configure do |config|
          config.global_options.add_options(defaults: {
            partial: "global_partial"
          })
        end
      end

      it "should set render_item to the default render strategy" do
        expect(runtime_context.render_item).to eql "global_partial"
      end

      context "when there is also an init option default render strategy provided" do
        let(:builder) { Blocks::Builder.new(view, { defaults: { partial: "init_partial" }}) }

        it "should set render_item to the default init option render strategy" do
          expect(runtime_context.render_item).to eql "init_partial"
        end

        context "when there is also a block proxy default render strategy provided" do
          let(:proxy_block_definition) { Proc.new {} }
          before do
            builder.define TEST_BLOCK, defaults: { with: :proxy_block_1 }
            builder.define :proxy_block_1, defaults: { with: :proxy_block_2 }
            builder.define :proxy_block_2, runtime: { with: :proxy_block_3 }
            builder.define :proxy_block_3, with: :proxy_block_4
            builder.define :proxy_block_4, &proxy_block_definition
          end

          it "should follow the proxies to the block definition to use" do
            expect(runtime_context.render_item).to eql proxy_block_definition
          end

          it "should set render_item to nil if the proxies don't lead to a block definition" do
            builder.block_definitions.delete(:proxy_block_4)
            expect(runtime_context.render_item).to be_nil
          end
        end

        context "when there is also a block default render strategy provided" do
          before do
            builder.define TEST_BLOCK, defaults: { partial: "test_block_partial" }
          end

          it "should set render_item to the default block render strategy" do
            expect(runtime_context.render_item).to eql "test_block_partial"
          end

          context "when there is also a render option default strategy provided" do
            let(:runtime_context) {
              Blocks::RuntimeContext.new(builder, TEST_BLOCK, defaults: {
                partial: "test_render_partial"
              })
            }

            it "should set render_item to the render option default strategy" do
              expect(runtime_context.render_item).to eql "test_render_partial"
            end

            context "when there is also a default runtime block provided" do
              let(:default_block) { Proc.new {} }
              let(:runtime_context) {
                Blocks::RuntimeContext.new(builder, TEST_BLOCK, defaults: {
                  partial: "test_render_partial"
                }, &default_block)
              }

              it "should set its render_item to the default block" do
                expect(runtime_context.render_item).to eql default_block
              end
            end
          end
        end
      end
    end
  end

  describe "when there are only standard options set" do
    context "when there is a global render strategy provided" do
      before do
        Blocks.configure do |config|
          config.global_options.add_options(
            partial: "global_partial"
          )
        end
      end

      it "should set render_item to the global render strategy" do
        expect(runtime_context.render_item).to eql "global_partial"
      end

      context "when there is an init option render strategy provided" do
        let(:builder) { Blocks::Builder.new(view, partial: "init_partial") }

        it "should set render_item to the init option render strategy" do
          expect(runtime_context.render_item).to eql "init_partial"
        end

        context "when there is also a block proxy render strategy provided" do
          let(:proxy_block_definition) { Proc.new {} }
          before do
            builder.define TEST_BLOCK, with: :proxy_block_1
            builder.define :proxy_block_1, defaults: { with: :proxy_block_2 }
            builder.define :proxy_block_2, runtime: { with: :proxy_block_3 }
            builder.define :proxy_block_3, with: :proxy_block_4
            builder.define :proxy_block_4, &proxy_block_definition
          end

          it "should follow the proxies to the block definition to use" do
            expect(runtime_context.render_item).to eql proxy_block_definition
          end

          it "should set render_item to nil if the proxies don't lead to a block definition" do
            builder.block_definitions.delete(:proxy_block_4)
            expect(runtime_context.render_item).to be_nil
          end
        end

        context "when there is also a block render strategy provided" do
          before do
            builder.define TEST_BLOCK, partial: "test_block_partial"
          end

          it "should set render_item to the block render strategy" do
            expect(runtime_context.render_item).to eql "test_block_partial"
          end

          context "when there is also a default runtime block provided" do
            let(:default_block) { Proc.new {} }
            let(:runtime_context) {
              Blocks::RuntimeContext.new(builder, TEST_BLOCK, &default_block)
            }

            it "should not set its render_item to the default block" do
              expect(runtime_context.render_item).not_to eql default_block
              expect(runtime_context.render_item).to eql "test_block_partial"
            end
          end
        end
      end
    end
  end

  describe "when there are only runtime options set"

  describe "when there are render strategies for default and standard options" do
    xit "should give priority to the lowest precedence standard render strategy over the highest default strategy" do

    end
  end

  describe "when there are render strategies for standard and runtime options" do
    xit "should give priority to the lowest precedence runtime render strategy over the highest standard strategy" do

    end
  end

end