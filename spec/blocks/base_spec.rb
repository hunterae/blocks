require "spec_helper"

describe Blocks::Base do
  before :each do
    @view = ActionView::Base.new
    @builder = Blocks::Base.new(@view)
  end

  it "should be able change the default global partials directory" do
    Blocks.setup do |config|
      config.partials_folder = "shared"
      config.use_partials = true
    end
    @builder = Blocks::Base.new(@view)
    @builder.expects(:render_before_blocks).at_least_once
    @builder.expects(:render_after_blocks).at_least_once
    # @view.expects(:capture).with(:value1 => 1, :value2 => 2).never
    @view.expects(:render).with("some_block", 'partials_folder' => 'shared', 'wrap_before_and_after_blocks' => false, 'use_partials' => true, 'skip_applies_to_surrounding_blocks' => false, 'value1' => 1, 'value2' => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
    @view.expects(:render).with("shared/some_block", 'partials_folder' => 'shared', 'wrap_before_and_after_blocks' => false, 'use_partials' => true, 'skip_applies_to_surrounding_blocks' => false, 'value1' => 1, 'value2' => 2).once
    @builder.render :some_block, :value1 => 1, :value2 => 2
  end

  describe "#defined?" do
    it "should be able to determine if a block by a specific name is already defined" do
      @builder.defined?(:test_block).should be false
      @builder.define :test_block do end
      @builder.defined?(:test_block).should be true
    end

    it "should not care whether the block name was defined with a string or a symbol" do
      @builder.defined?(:test_block).should be false
      @builder.define "test_block" do end
      @builder.defined?(:test_block).should be true

      @builder.defined?(:test_block2).should be false
      @builder.define :test_block2 do end
      @builder.defined?(:test_block2).should be true
    end

    it "should not care whether the defined? method is passed a string or a symbol" do
      @builder.defined?("test_block").should be false
      @builder.define :test_block do end
      @builder.defined?("test_block").should be true
    end
  end

  describe "#define" do
    it "should be able to define a new block" do
      block = Proc.new { |options| }

      @builder.define :test_block, :option1 => "value1", :option2 => "value2", &block

      test_block = @builder.blocks[:test_block]
      test_block.options[:option1].should eql("value1")
      test_block.options[:option2].should eql("value2")
      test_block.name.should eql(:test_block)
      test_block.block.should eql(block)
    end

    it "should not replace a defined block with another attempted definition" do
      block1 = Proc.new do |options| end
      @builder.define :test_block, :option1 => "value1", :option2 => "value2", &block1

      block2 = Proc.new do |options| end
      @builder.define :test_block, :option3 => "value3", :option4 => "value4", &block2

      test_block = @builder.blocks[:test_block]
      test_block.options[:option1].should eql("value1")
      test_block.options[:option2].should eql("value2")
      test_block.options[:option3].should be_nil
      test_block.options[:option4].should be_nil
      test_block.name.should eql(:test_block)
      test_block.block.should eql(block1)
    end

    it "should be able to define a collection of blocks" do
      block = Proc.new {}
      collection = ["block1", "block2", "block3"]
      @builder.define Proc.new {|block_name| block_name }, :collection => collection, &block
      @builder.blocks[:block1].should be_present
      @builder.blocks[:block1].block.should eql block
      @builder.blocks[:block2].should be_present
      @builder.blocks[:block2].block.should eql block
      @builder.blocks[:block3].should be_present
      @builder.blocks[:block3].block.should eql block
    end
  end

  describe "#replace" do
    it "should be able to replace a defined block" do
      block1 = Proc.new do |options| end
      @builder.define :test_block, :option1 => "value1", :option2 => "value2", &block1

      block2 = Proc.new do |options| end
      @builder.replace :test_block, :option3 => "value3", :option4 => "value4", &block2

      test_block = @builder.blocks[:test_block]
      test_block.options[:option1].should be_nil
      test_block.options[:option2].should be_nil
      test_block.options[:option3].should eql("value3")
      test_block.options[:option4].should eql("value4")
      test_block.name.should eql(:test_block)
      test_block.block.should eql(block2)
    end
  end

  describe "#skip" do
    it "should define an empty block" do
      @builder.skip(:test_block)
      @builder.blocks[:test_block].should be_present
      @builder.blocks[:test_block].block.call.should be_nil
    end
  end

  describe "#before" do
    it "should be aliased with prepend" do
      block = Proc.new { |options| }
      @builder.prepend :some_block, &block
      @builder.blocks[:before_some_block].should be_present
    end

    it "should define before blocks as the block name with the word 'before_' prepended to it" do
      block = Proc.new { |options| }
      @builder.before :some_block, &block
      @builder.blocks[:before_some_block].should be_present
    end

    it "should store a before block in an array" do
      block = Proc.new { |options| }
      @builder.before :some_block, &block
      before_blocks = @builder.blocks[:before_some_block]
      before_blocks.should be_a(Array)
    end

    it "should store a before block as a Blocks::Container" do
      block = Proc.new { |options| }
      @builder.before :some_block, :option1 => "some option", &block
      before_blocks = @builder.blocks[:before_some_block]
      block_container = before_blocks.first
      block_container.should be_a(Blocks::Container)
      block_container.options.should eql :option1 => "some option"
      block_container.block.should eql block
    end

    it "should queue before blocks if there are multiple defined" do
      block = Proc.new { |options| }
      block2 = Proc.new { |options| }
      @builder.before :some_block, &block
      @builder.before :some_block, &block2
      before_blocks = @builder.blocks[:before_some_block]
      before_blocks.length.should eql 2
    end

    it "should store before blocks in the order in which they are defined" do
      block = Proc.new { |options| }
      block2 = Proc.new { |options| }
      block3 = Proc.new { |options| }
      @builder.before :some_block, &block
      @builder.before :some_block, &block2
      @builder.before :some_block, &block3
      before_blocks = @builder.blocks[:before_some_block]
      before_blocks.first.block.should eql block
      before_blocks.second.block.should eql block2
      before_blocks.third.block.should eql block3
    end
  end

  describe "#after" do
    it "should be aliased with append and for" do
      block = Proc.new { |options| }
      @builder.append :some_block, &block
      @builder.blocks[:after_some_block].should be_present

      block = Proc.new { |options| }
      @builder.for :some_block, &block
      @builder.blocks[:after_some_block].should be_present
    end

    it "should define after blocks as the block name with the word 'after_' prepended to it" do
      block = Proc.new { |options| }
      @builder.after :some_block, &block
      @builder.blocks[:after_some_block].should be_present
    end

    it "should store a after block in an array" do
      block = Proc.new { |options| }
      @builder.after :some_block, &block
      after_blocks = @builder.blocks[:after_some_block]
      after_blocks.should be_a(Array)
    end

    it "should store a after block as a Blocks::Container" do
      block = Proc.new { |options| }
      @builder.after :some_block, :option1 => "some option", &block
      after_blocks = @builder.blocks[:after_some_block]
      block_container = after_blocks.first
      block_container.should be_a(Blocks::Container)
      block_container.options.should eql :option1 => "some option"
      block_container.block.should eql block
    end

    it "should queue after blocks if there are multiple defined" do
      block = Proc.new { |options| }
      block2 = Proc.new { |options| }
      @builder.after :some_block, &block
      @builder.after :some_block, &block2
      after_blocks = @builder.blocks[:after_some_block]
      after_blocks.length.should eql 2
    end

    it "should store after blocks in the order in which they are defined" do
      block = Proc.new { |options| }
      block2 = Proc.new { |options| }
      block3 = Proc.new { |options| }
      @builder.after :some_block, &block
      @builder.after :some_block, &block2
      @builder.after :some_block, &block3
      after_blocks = @builder.blocks[:after_some_block]
      after_blocks.first.block.should eql block
      after_blocks.second.block.should eql block2
      after_blocks.third.block.should eql block3
    end
  end

  describe "#around" do
    it "should define around blocks as the block name with the word 'around_' prepended to it" do
      block = Proc.new { |options| }
      @builder.around :some_block, &block
      @builder.blocks[:around_some_block].should be_present
    end

    it "should store a around block in an array" do
      block = Proc.new { |options| }
      @builder.around :some_block, &block
      around_blocks = @builder.blocks[:around_some_block]
      around_blocks.should be_a(Array)
    end

    it "should store a around block as a Blocks::Container" do
      block = Proc.new { |options| }
      @builder.around :some_block, :option1 => "some option", &block
      around_blocks = @builder.blocks[:around_some_block]
      block_container = around_blocks.first
      block_container.should be_a(Blocks::Container)
      block_container.options.should eql :option1 => "some option"
      block_container.block.should eql block
    end

    it "should queue around blocks if there are multiple defined" do
      block = Proc.new { |options| }
      block2 = Proc.new { |options| }
      @builder.around :some_block, &block
      @builder.around :some_block, &block2
      around_blocks = @builder.blocks[:around_some_block]
      around_blocks.length.should eql 2
    end

    it "should store after blocks in the order in which they are defined" do
      block = Proc.new { |options| }
      block2 = Proc.new { |options| }
      block3 = Proc.new { |options| }
      @builder.around :some_block, &block
      @builder.around :some_block, &block2
      @builder.around :some_block, &block3
      around_blocks = @builder.blocks[:around_some_block]
      around_blocks.first.block.should eql block
      around_blocks.second.block.should eql block2
      around_blocks.third.block.should eql block3
    end
  end

  describe "#render_with_partials" do
    it "should trigger the call to #render with :use_partials set to true" do
      @builder.expects(:render).with(:some_block, :use_partials => true)
      @builder.render_with_partials(:some_block)
    end
  end

  describe "#render_without_partials" do
    it "should trigger the call to #render with :skip_partials set to true" do
      @builder.expects(:render).with(:some_block, :skip_partials => true)
      @builder.render_without_partials(:some_block)
    end
  end

  describe "#render" do
    it "should alias the render method as use" do
      block = Proc.new {"output"}
      @builder.define :some_block, &block
      @builder.use(:some_block).should eql "output"
    end

    it "should be able to render a defined block by its name" do
      block = Proc.new {"output"}
      @builder.define :some_block, &block
      @builder.render(:some_block).should eql "output"
    end

    it "should automatically pass in an options hash to a defined block that takes one paramter when that block is rendered" do
      block = Proc.new {|options| print_hash(options) }
      @builder.define :some_block, &block
      @builder.render(:some_block).should eql print_hash(:wrap_before_and_after_blocks => false, :use_partials => false, :partials_folder => "blocks", :skip_applies_to_surrounding_blocks => false)
    end

    it "should be able to render a defined block by its name and pass in runtime arguments as a hash" do
      block = Proc.new do |options|
        print_hash(options)
      end
      @builder.define :some_block, &block
      @builder.render(:some_block, :param1 => 1, :param2 => "value2").should eql print_hash(:wrap_before_and_after_blocks => false, :use_partials => false, :partials_folder => "blocks", :skip_applies_to_surrounding_blocks => false, :param1 => 1, :param2 => "value2")
    end

    it "should be able to render a defined block by its name and pass in runtime arguments one by one" do
      block = Proc.new do |first_param, second_param, options|
        "first_param: #{first_param}, second_param: #{second_param}, #{print_hash options}"
      end
      @builder.define :some_block, &block
      @builder.render(:some_block, 3, 4, :param1 => 1, :param2 => "value2").should eql("first_param: 3, second_param: 4, #{print_hash(:wrap_before_and_after_blocks => false, :use_partials => false, :partials_folder => "blocks", :skip_applies_to_surrounding_blocks => false, :param1 => 1, :param2 => "value2")}")
    end

    it "should match up the number of arguments to a defined block with the parameters passed when a block is rendered" do
      block = Proc.new {|first_param| "first_param = #{first_param}"}
      @builder.define :some_block, &block
      @builder.render(:some_block, 3, 4, :param1 => 1, :param2 => "value2").should eql "first_param = 3"

      block = Proc.new {|first_param, second_param| "first_param = #{first_param}, second_param = #{second_param}"}
      @builder.replace :some_block, &block
      @builder.render(:some_block, 3, 4, :param1 => 1, :param2 => "value2").should eql "first_param = 3, second_param = 4"

      block = Proc.new do |first_param, second_param, options|
        "first_param: #{first_param}, second_param: #{second_param}, #{print_hash options}"
      end
      @builder.replace :some_block, &block
      @builder.render(:some_block, 3, 4, :param1 => 1, :param2 => "value2").should eql("first_param: 3, second_param: 4, #{print_hash(:wrap_before_and_after_blocks => false, :use_partials => false, :partials_folder => "blocks", :skip_applies_to_surrounding_blocks => false, :param1 => 1, :param2 => "value2")}")
    end

    it "should not render anything if using a block that has been defined" do
      Blocks.setup do |config|
        config.use_partials = true
      end
      @builder = Blocks::Base.new(@view)
      @view.expects(:render).with("some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => true, 'skip_applies_to_surrounding_blocks' => false).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @view.expects(:render).with("blocks/some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => true, 'skip_applies_to_surrounding_blocks' => false).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @builder.render :some_block
    end

    it "should first attempt to capture a block's contents when blocks.render is called" do
      block = Proc.new {|options|}
      @view.expects(:render).with("some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => true, 'value1' => 1, 'value2' => 2).never
      @view.expects(:render).with("blocks/some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => true, 'value1' => 1, 'value2' => 2).never
      @builder.define :some_block, &block
      @builder.render :some_block, :value1 => 1, :value2 => 2
    end

    it "should second attempt to render a local partial by the block's name when blocks.render is called" do
      Blocks.setup do |config|
        config.use_partials = true
      end
      @builder = Blocks::Base.new(@view)
      @view.expects(:render).with("some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => true, 'skip_applies_to_surrounding_blocks' => false, 'value1' => 1, 'value2' => 2).once
      @view.expects(:render).with("blocks/some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => true, 'skip_applies_to_surrounding_blocks' => false, 'value1' => 1, 'value2' => 2).never
      @builder.render :some_block, :value1 => 1, :value2 => 2
    end

    it "should third attempt to render a global partial by the block's name when blocks.render is called" do
      Blocks.setup do |config|
        config.use_partials = true
      end
      @builder = Blocks::Base.new(@view)
      @view.expects(:render).with("some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => true, 'skip_applies_to_surrounding_blocks' => false, 'value1' => 1, 'value2' => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @view.expects(:render).with("blocks/some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => true, 'skip_applies_to_surrounding_blocks' => false, 'value1' => 1, 'value2' => 2).once
      @builder.render :some_block, :value1 => 1, :value2 => 2
    end

    it "should fourth attempt to render a default block when blocks.render is called" do
      block = Proc.new do |options|
        options[:value1].should eql 1
        options[:value2].should eql 2
      end
      Blocks.setup do |config|
        config.use_partials = true
      end
      @builder = Blocks::Base.new(@view)
      @view.expects(:render).with("some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => true, 'skip_applies_to_surrounding_blocks' => false, 'value1' => 1, 'value2' => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @view.expects(:render).with("blocks/some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => true, 'skip_applies_to_surrounding_blocks' => false, 'value1' => 1, 'value2' => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @builder.render :some_block, :value1 => 1, :value2 => 2, &block
    end

    it "should not attempt to render a partial if use_partials is set to false" do
      block = Proc.new do |options|
        options[:value1].should eql 1
        options[:value2].should eql 2
      end
      @view.expects(:render).with("some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => false, 'skip_applies_to_surrounding_blocks' => false, 'value1' => 1, 'value2' => 2).never
      @view.expects(:render).with("blocks/some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => false, 'skip_applies_to_surrounding_blocks' => false, 'value1' => 1, 'value2' => 2).never
      @builder.render :some_block, :value1 => 1, :value2 => 2, &block
    end

    it "should not attempt to render a partial if use_partials is passed in as false as an option to Blocks::Base.new" do
      mocha_teardown
      @builder = Blocks::Base.new(@view, :use_partials => false)
      @builder.expects(:render_before_blocks).at_least_once
      @builder.expects(:render_after_blocks).at_least_once
      block = Proc.new do |options|
        options[:value1].should eql 1
        options[:value2].should eql 2
      end
      @view.expects(:render).with("some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => false, 'skip_applies_to_surrounding_blocks' => false, 'value1' => 1, 'value2' => 2).never
      @view.expects(:render).with("blocks/some_block", 'partials_folder' => 'blocks', 'wrap_before_and_after_blocks' => false, 'use_partials' => false, 'skip_applies_to_surrounding_blocks' => false, 'value1' => 1, 'value2' => 2).never
      @builder.render :some_block, :value1 => 1, :value2 => 2, &block
    end

    it "should override hash options for a block by merging the runtime options into the define default options into the queue level options into the global options" do
      block = Proc.new do |options|
        options[:param1].should eql "use level"
        options[:param2].should eql "queue level"
        options[:param3].should eql "define level"
        options[:param4].should eql "global level"
      end
      @builder.global_options.merge!(:param1 => "global level", :param2 => "global level", :param3 => "global level", :param4 => "global level")
      block_container = @builder.send(:define_block_container, :my_before_block, :param1 => "queue level", :param2 => "queue level")
      @builder.define(:my_before_block, :param1 => "define level", :param2 => "define level", :param3 => "define level", &block)
      @builder.render block_container, :param1 => "use level"
    end

    it "should render the contents of a defined block when that block is used" do
      block = Proc.new {}
      @view.expects(:capture).with(nil).returns("rendered content")
      @builder.define :some_block, &block
      buffer = @builder.render :some_block
      buffer.should eql "rendered content"
    end

    it "should be able to render an element surrounding the block" do
      block = Proc.new {}
      @view.expects(:capture).with(nil).returns("rendered content")
      @builder.define :some_block, &block
      buffer = @builder.render :some_block, :wrap_with => {:tag => "span", :id => "my-id"}
      buffer.should eql "<span id=\"my-id\">rendered content</span>"
    end

    describe "with a collection passed in" do
      it "should render a block for each element of the collection with the name of the block used as the name of the element passed into the block" do
        block = Proc.new {|item, options| "output#{options[:some_block]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3]).should eql "output1 output2 output3 "
      end

      it "should track the current index and pass as an option to the block" do
        block = Proc.new {|item, options| "Item #{options[:current_index] + 1}: #{item} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => ["a", "b", "c"]).should eql "Item 1: a Item 2: b Item 3: c "
      end

      it "should render a block for each element of the collection with the 'as' option specifying the name of the element passed into the block" do
        block = Proc.new {|item, options| "output#{options[:my_block_name]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3], :as => "my_block_name").should eql "output1 output2 output3 "
      end

      it "should render a block for each element of the collection with a surrounding element if that option is specified" do
        block = Proc.new {|item, options| "output#{options[:my_block_name]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3], :wrap_each => {:tag => "div"}).should eql "<div>output </div><div>output </div><div>output </div>"
      end

      it "should render a block for each element of the collection with a surrounding element and specified html options if those options are specified" do
        block = Proc.new {|item, options| "output#{options[:my_block_name]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3], :wrap_each => {:tag => "div", :class => lambda { @view.cycle("even", "odd")}, :style => "color:red"}).should eql "<div class=\"even\" style=\"color:red\">output </div><div class=\"odd\" style=\"color:red\">output </div><div class=\"even\" style=\"color:red\">output </div>"
      end

      it "should be able to render before blocks before each element of a collection" do
        before_block = Proc.new {|item, options| "before#{options[:some_block]} "}
        @builder.before :some_block, &before_block

        block = Proc.new {|item, options| "output#{options[:some_block]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3]).should eql "before1 output1 before2 output2 before3 output3 "
      end

      it "should be able to render after blocks before each element of a collection" do
        after_block = Proc.new {|item, options| "after#{options[:some_block]} "}
        @builder.after :some_block, &after_block

        block = Proc.new {|item, options| "output#{options[:some_block]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3]).should eql "output1 after1 output2 after2 output3 after3 "
      end

      it "should be able to render before and after blocks before each element of a collection" do
        before_block = Proc.new {|item, options| "before#{options[:some_block]} "}
        @builder.before :some_block, &before_block

        after_block = Proc.new {|item, options| "after#{options[:some_block]} "}
        @builder.after :some_block, &after_block

        block = Proc.new {|item, options| "output#{options[:some_block]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3]).should eql "before1 output1 after1 before2 output2 after2 before3 output3 after3 "
      end

      it "should by default render surrounding elements outside before and after blocks" do
        before_block = Proc.new {|item, options| "before#{options[:some_block]} "}
        @builder.before :some_block, &before_block

        after_block = Proc.new {|item, options| "after#{options[:some_block]} "}
        @builder.after :some_block, &after_block

        block = Proc.new {|item, options| "output#{options[:some_block]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3], :wrap_each => {:tag => "div"}).should eql "before1 <div>output1 </div>after1 before2 <div>output2 </div>after2 before3 <div>output3 </div>after3 "
      end

      it "should allow the global option to be set to render before and after blocks inside of surrounding elements" do
        Blocks.setup do |config|
          config.wrap_before_and_after_blocks = true
        end
        @builder = Blocks::Base.new(@view)
        before_block = Proc.new {|item, options| "before#{options[:some_block]} "}
        @builder.before :some_block, &before_block

        after_block = Proc.new {|item, options| "after#{options[:some_block]} "}
        @builder.after :some_block, &after_block

        block = Proc.new {|item, options| "output#{options[:some_block]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3], :wrap_each => {:tag => "div"}).should eql "<div>before1 output1 after1 </div><div>before2 output2 after2 </div><div>before3 output3 after3 </div>"
      end

      it "should allow the option to be set to render before and after blocks outside of surrounding elements to be specified when Blocks is initialized" do
        @builder = Blocks::Base.new(@view, :wrap_before_and_after_blocks => false)
        before_block = Proc.new {|item, options| "before#{options[:some_block]} "}
        @builder.before :some_block, &before_block

        after_block = Proc.new {|item, options| "after#{options[:some_block]} "}
        @builder.after :some_block, &after_block

        block = Proc.new {|item, options| "output#{options[:some_block]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3], :wrap_each => {:tag => "div"}).should eql "before1 <div>output1 </div>after1 before2 <div>output2 </div>after2 before3 <div>output3 </div>after3 "
      end

      it "should be able to render an element around everything" do
        before_block = Proc.new {|item, options| "before#{options[:some_block]} "}
        @builder.before :some_block, &before_block

        after_block = Proc.new {|item, options| "after#{options[:some_block]} "}
        @builder.after :some_block, &after_block

        block = Proc.new {|item, options| "output#{options[:some_block]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3], :wrap_each => {:tag => "div"}, :wrap_with => {:tag => "div", :style => "color:red"}).should eql "<div style=\"color:red\">before1 <div>output1 </div>after1 before2 <div>output2 </div>after2 before3 <div>output3 </div>after3 </div>"
      end
    end
  end

  describe "render method - before blocks" do
    before :each do
      @builder.expects(:render_block).at_least_once
      @builder.expects(:render_after_blocks).at_least_once
    end

    it "should render before blocks when using a block" do
      block = Proc.new do |value1, value2, options|
        value1.should eql 1
        value2.should eql 2
        options[:value3].should eql 3
        options[:value4].should eql 4
      end
      @builder.before("my_before_block", &block)
      @builder.render :my_before_block, 1, 2, :value3 => 3, :value4 => 4
    end

    it "should override hash options for before blocks by merging the runtime options into the before block options into the block options into the global options" do
      block = Proc.new do |options|
        options[:param1].should eql "top level"
        options[:param2].should eql "before block level"
        options[:param3].should eql "block level"
        options[:param4].should eql "global level"
      end
      @builder.global_options.merge!(:param1 => "global level", :param2 => "global level", :param3 => "global level", :param4 => "global level")
      @builder.define(:my_before_block, :param1 => "block level", :param2 => "block level", :param3 => "block level", &block)
      @builder.before(:my_before_block, :param1 => "before block level", :param2 => "before block level", &block)
      @builder.render :my_before_block, :param1 => "top level"
    end
  end

  describe "render method - around blocks" do
    it "should be able to render code around another block" do
      my_block = Proc.new { "test" }
      around_block = Proc.new { |content_block| "<span>#{content_block.call}</span>" }
      @builder.define(:my_block, &my_block)
      @builder.around(:my_block, &around_block)
      @builder.render(:my_block).should eql("&lt;span&gt;test&lt;/span&gt;")
    end

    it "should be able to nest multiple around blocks with the last defined around block on the outside" do
      my_block = Proc.new { "test" }
      around_block1 = Proc.new { |content_block| @view.content_tag :h1, content_block.call }
      around_block2 = Proc.new { |content_block| @view.content_tag :span, content_block.call, :style => "font-size: 100px" }
      around_block3 = Proc.new { |content_block| @view.content_tag :span, content_block.call, :style => "style='color:red" }
      @builder.define(:my_block, &my_block)
      @builder.around(:my_block, &around_block1)
      @builder.around(:my_block, &around_block2)
      @builder.around(:my_block, &around_block3)
      @builder.render(:my_block).should eql(%%<h1><span style="font-size: 100px"><span style="style=&#39;color:red">test</span></span></h1>%)
    end
  end

  describe "render method - after blocks" do
    before :each do
      @builder.expects(:render_block).at_least_once
      @builder.expects(:render_before_blocks).at_least_once
    end

    it "should render after blocks when using a block" do
      block = Proc.new do |value1, value2, options|
        value1.should eql 1
        value2.should eql 2
        options[:value3].should eql 3
        options[:value4].should eql 4
      end
      @builder.after("my_after_block", &block)
      @builder.render :my_after_block, 1, 2, :value3 => 3, :value4 => 4
    end

    it "should override hash options for after blocks by merging the runtime options into the after block options into the block options into the global options" do
      block = Proc.new do |options|
        options[:param1].should eql "top level"
        options[:param2].should eql "after block level"
        options[:param3].should eql "block level"
        options[:param4].should eql "global level"
      end
      @builder.global_options.merge!(:param1 => "global level", :param2 => "global level", :param3 => "global level", :param4 => "global level")
      @builder.define(:my_after_block, :param1 => "block level", :param2 => "block level", :param3 => "block level", &block)
      @builder.after(:my_after_block, :param1 => "after block level", :param2 => "after block level", &block)
      @builder.render :my_after_block, :param1 => "top level"
    end
  end
end
