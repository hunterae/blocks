require 'spec_helper'

feature "Rendering Option Merging" do
  TEST_BLOCK = :test_block

  let(:builder) { Blocks::Builder.new(view) }
  let(:runtime_context) { Blocks::RuntimeContext.new(builder, TEST_BLOCK) }

  context "with global options present" do
    before do
      Blocks.configure do |config|
        global_options = config.global_options
        config.global_options.add_options(
          defaults: {
            default_option: "global default",
            shared_option: "global default"
          },
          runtime: {
            runtime_option: "global runtime",
            shared_option: "global runtime"
          },
          standard_option: "global standard",
          shared_option: "global standard"
        )
      end
    end

    it "should merge options runtime into standard into defaults" do
      expect(runtime_context[:shared_option]).to eql "global runtime"
      expect(runtime_context[:default_option]).to eql "global default"
      expect(runtime_context[:runtime_option]).to eql "global runtime"
      expect(runtime_context[:standard_option]).to eql "global standard"
    end

    context "with init_options present" do
      let(:init_options) do
        {
          defaults: {
            default_option: "init default",
            shared_option: "init default"
          },
          runtime: {
            runtime_option: "init runtime",
            shared_option: "init runtime"
          },
          standard_option: "init standard",
          shared_option: "init standard"
        }
      end
      let(:builder) { Blocks::Builder.new(view, init_options) }

      it "should merge options (with precedence for the init options) runtime into standard into defaults" do
        expect(runtime_context[:shared_option]).to eql "init runtime"
        expect(runtime_context[:default_option]).to eql "init default"
        expect(runtime_context[:runtime_option]).to eql "init runtime"
        expect(runtime_context[:standard_option]).to eql "init standard"
      end

      context "with block options present" do
        before do
          builder.define TEST_BLOCK,
            defaults: {
              default_option: "test_block default",
              shared_option: "test_block default"
            },
            runtime: {
              runtime_option: "test_block runtime",
              shared_option: "test_block runtime"
            },
            standard_option: "test_block standard",
            shared_option: "test_block standard"
        end

        it "should merge options (with precedence for the block options) runtime into standard into defaults" do
          expect(runtime_context[:shared_option]).to eql "test_block runtime"
          expect(runtime_context[:default_option]).to eql "test_block default"
          expect(runtime_context[:runtime_option]).to eql "test_block runtime"
          expect(runtime_context[:standard_option]).to eql "test_block standard"
        end

        it "should give precedence to block options over proxy options" do
          builder.define TEST_BLOCK, with: :proxy_1
          3.times do |i|
            proxy_block_name = "proxy_#{ i + 1 }"
            builder.define proxy_block_name,
              defaults: {
                default_option: "#{proxy_block_name} default",
                shared_option: "#{proxy_block_name} default",
                shared_proxy_option: "#{proxy_block_name} default"
              },
              runtime: {
                runtime_option: "#{proxy_block_name} runtime",
                shared_option: "#{proxy_block_name} runtime",
                shared_proxy_option: "#{proxy_block_name} runtime"
              },
              proxy_block_name => "#{proxy_block_name} standard",
              shared_proxy_option: "#{proxy_block_name} standard",
              standard_option: "#{proxy_block_name} standard",
              shared_option: "#{proxy_block_name} standard",
              with: "proxy_#{ i + 2 }"
          end

          expect(runtime_context[:shared_option]).to eql "test_block runtime"
          expect(runtime_context[:default_option]).to eql "test_block default"
          expect(runtime_context[:runtime_option]).to eql "test_block runtime"
          expect(runtime_context[:standard_option]).to eql "test_block standard"
          expect(runtime_context[:shared_proxy_option]).to eql "proxy_1 runtime"
          3.times do |i|
            expect(runtime_context["proxy_#{i+1}"]).to eql "proxy_#{i+1} standard"
          end
        end

        context "with render options present" do
          let(:runtime_context) do
            Blocks::RuntimeContext.new(builder, TEST_BLOCK, {
              defaults: {
                default_option: "render default",
                shared_option: "render default"
              },
              runtime_option: "render runtime",
              shared_option: "render runtime"
            })
          end

          it "should merge options (with precedence for the render options) runtime into standard into defaults" do
            expect(runtime_context[:shared_option]).to eql "render runtime"
            expect(runtime_context[:default_option]).to eql "render default"
            expect(runtime_context[:runtime_option]).to eql "render runtime"
            expect(runtime_context[:standard_option]).to eql "test_block standard"
          end
        end

      end
    end
  end
end