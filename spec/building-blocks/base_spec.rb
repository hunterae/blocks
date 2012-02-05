require "spec_helper"

describe BuildingBlocks::Base do
  before :each do
    @view = ActionView::Base.new
    @builder = BuildingBlocks::Base.new(@view)
  end

  it "should be able change the default global partials directory" do
    BuildingBlocks.send(:remove_const, "TEMPLATE_FOLDER")
    BuildingBlocks.const_set("TEMPLATE_FOLDER", "shared")
    @builder = BuildingBlocks::Base.new(@view)
    @builder.expects(:render_before_blocks).at_least_once
    @builder.expects(:render_after_blocks).at_least_once
    @view.expects(:capture).with(:value1 => 1, :value2 => 2).never
    @view.expects(:render).with("some_block", :value1 => 1, :value2 => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
    @view.expects(:render).with("shared/some_block", :value1 => 1, :value2 => 2).once
    @builder.use :some_block, :value1 => 1, :value2 => 2
    BuildingBlocks.send(:remove_const, "TEMPLATE_FOLDER")
    BuildingBlocks.const_set("TEMPLATE_FOLDER", "blocks")
  end

  describe "defined? method" do
    it "should be able to determine if a block by a specific name is already defined" do
      @builder.defined?(:test_block).should be_false
      @builder.define :test_block do end
      @builder.defined?(:test_block).should be_true
    end

    it "should not care whether the block name was defined with a string or a symbol" do
      @builder.defined?(:test_block).should be_false
      @builder.define "test_block" do end
      @builder.defined?(:test_block).should be_true

      @builder.defined?(:test_block2).should be_false
      @builder.define :test_block2 do end
      @builder.defined?(:test_block2).should be_true
    end

    it "should not care whether the defined? method is passed a string or a symbol" do
      @builder.defined?("test_block").should be_false
      @builder.define :test_block do end
      @builder.defined?("test_block").should be_true
    end
  end

  describe "define method" do
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
  end

  describe "replace method" do
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

  describe "queue method" do
    it "should store all queued blocks in the queued_blocks array" do
      @builder.queued_blocks.should be_empty
      @builder.queue :test_block
      @builder.queued_blocks.length.should eql 1
      @builder.queued_blocks.map(&:name).first.should eql(:test_block)
    end

    it "should convert a string block name to a symbol" do
      @builder.queue "test_block"
      @builder.queued_blocks.map(&:name).first.should eql(:test_block)
    end

    it "should queue blocks as BuildingBlocks::Container objects" do
      @builder.queue :test_block, :a => 1, :b => 2, :c => 3
      container = @builder.queued_blocks.first
      container.should be_a(BuildingBlocks::Container)
      container.name.should eql(:test_block)
      container.options.should eql(:a => 1, :b => 2, :c => 3)
    end

    it "should not require a name for the block being queued" do
      @builder.queue
      @builder.queue
      @builder.queued_blocks.length.should eql 2
      @builder.queued_blocks.map(&:name).first.should eql(:block_1)
      @builder.queued_blocks.map(&:name).second.should eql(:block_2)
    end

    it "should anonymously define the name of a block if not specified" do
      @builder.queue
      @builder.queue :my_block
      @builder.queue
      @builder.queued_blocks.map(&:name).first.should eql(:block_1)
      @builder.queued_blocks.map(&:name).second.should eql(:my_block)
      @builder.queued_blocks.map(&:name).third.should eql(:block_2)
    end

    it "should store queued blocks in the order in which they are queued" do
      @builder.queue :block1
      @builder.queue :block3
      @builder.queue :block2
      @builder.queued_blocks.map(&:name).first.should eql(:block1)
      @builder.queued_blocks.map(&:name).second.should eql(:block3)
      @builder.queued_blocks.map(&:name).third.should eql(:block2)
    end

    it "should allow a definition to be provided for a queued block" do
      block = Proc.new do |options| end
      @builder.queue :test_block, &block
      container = @builder.queued_blocks.first
      container.block.should eql block
    end
  end

  describe "render method" do
    it "should raise an exception if no :template parameter is specified in the options hash" do
      view = mock()
      builder = BuildingBlocks::Base.new(view)
      lambda { builder.render }.should raise_error("Must specify :template parameter in order to render")
    end

    it "should attempt to render a partial specified as the :template parameter" do
      view = mock()
      builder = BuildingBlocks::Base.new(view, :template => "my_template")
      view.expects(:render).with{ |template, options| template.should eql "my_template"}
      builder.render
    end

    it "should set all of the global options as local variables to the partial it renders" do
      view = mock()
      builder = BuildingBlocks::Base.new(view, :template => "some_template")
      view.expects(:render).with { |template, options| options.should eql :template => 'some_template', :blocks => builder }
      builder.render
    end

    it "should capture the data of a block if a block has been specified" do
      block = Proc.new { |options| "my captured block" }
      builder = BuildingBlocks::Base.new(@view, :template => "template", &block)
      @view.expects(:render).with { |tempate, options| options[:captured_block].should eql("my captured block") }
      builder.render
    end

    it "should by default add a variable to the partial called 'blocks' as a pointer to the BuildingBlocks::Base instance" do
      view = mock()
      builder = BuildingBlocks::Base.new(view, :template => "some_template")
      view.expects(:render).with { |template, options| options[:blocks].should eql(builder) }
      builder.render
    end

    it "should allow the user to override the local variable passed to the partial as a pointer to the BuildingBlocks::Base instance" do
      view = mock()
      builder = BuildingBlocks::Base.new(view, :variable => "my_variable", :template => "some_template")
      view.expects(:render).with { |template, options| options[:blocks].should be_nil }
      builder.render
    end
  end

  describe "before method" do
    it "should defined before blocks as the block name with the word 'before_' prepended to it" do
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

    it "should store a before block as a BuildingBlocks::Container" do
      block = Proc.new { |options| }
      @builder.before :some_block, :option1 => "some option", &block
      before_blocks = @builder.blocks[:before_some_block]
      block_container = before_blocks.first
      block_container.should be_a(BuildingBlocks::Container)
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

  describe "after method" do
    it "should defined after blocks as the block name with the word 'after_' prepended to it" do
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

    it "should store a after block as a BuildingBlocks::Container" do
      block = Proc.new { |options| }
      @builder.after :some_block, :option1 => "some option", &block
      after_blocks = @builder.blocks[:after_some_block]
      block_container = after_blocks.first
      block_container.should be_a(BuildingBlocks::Container)
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

  describe "use method" do
    before :each do
      @builder.expects(:render_before_blocks).at_least_once
      @builder.expects(:render_after_blocks).at_least_once
    end

    it "should be able to use a defined block by its name" do
      block = Proc.new {"output"}
      @builder.define :some_block, &block
      @builder.use(:some_block).should eql "output"
    end

    it "should automatically pass in an options hash to a defined block that takes one paramter when that block is used" do
      block = Proc.new {|options| "Options are #{options.inspect}"}
      @builder.define :some_block, &block
      @builder.use(:some_block).should eql "Options are {}"
    end

    it "should be able to use a defined block by its name and pass in runtime arguments as a hash" do
      block = Proc.new do |options|
        print_hash(options)
      end
      @builder.define :some_block, &block
      @builder.use(:some_block, :param1 => 1, :param2 => "value2").should eql print_hash(:param1 => 1, :param2 => "value2")
    end

    it "should be able to use a defined block by its name and pass in runtime arguments one by one" do
      block = Proc.new do |first_param, second_param, options|
        "first_param: #{first_param}, second_param: #{second_param}, #{print_hash options}"
      end
      @builder.define :some_block, &block
      @builder.use(:some_block, 3, 4, :param1 => 1, :param2 => "value2").should eql("first_param: 3, second_param: 4, #{print_hash(:param1 => 1, :param2 => "value2")}")
    end

    it "should match up the number of arguments to a defined block with the parameters passed when a block is used" do
      block = Proc.new {|first_param| "first_param = #{first_param}"}
      @builder.define :some_block, &block
      @builder.use(:some_block, 3, 4, :param1 => 1, :param2 => "value2").should eql "first_param = 3"

      block = Proc.new {|first_param, second_param| "first_param = #{first_param}, second_param = #{second_param}"}
      @builder.replace :some_block, &block
      @builder.use(:some_block, 3, 4, :param1 => 1, :param2 => "value2").should eql "first_param = 3, second_param = 4"

      block = Proc.new do |first_param, second_param, options|
        "first_param: #{first_param}, second_param: #{second_param}, #{print_hash options}"
      end
      @builder.replace :some_block, &block
      @builder.use(:some_block, 3, 4, :param1 => 1, :param2 => "value2").should eql("first_param: 3, second_param: 4, #{print_hash(:param1 => 1, :param2 => "value2")}")
    end

    it "should not render anything if using a block that has been defined" do
      @view.expects(:capture).never
      @view.expects(:render).with("some_block", {}).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @view.expects(:render).with("blocks/some_block", {}).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @builder.use :some_block
    end

    it "should first attempt to capture a block's contents when blocks.use is called" do
      block = Proc.new {|options|}
      @view.expects(:capture).with(:value1 => 1, :value2 => 2)
      @view.expects(:render).with("some_block", :value1 => 1, :value2 => 2).never
      @view.expects(:render).with("blocks/some_block", :value1 => 1, :value2 => 2).never
      @builder.define :some_block, &block
      @builder.use :some_block, :value1 => 1, :value2 => 2
    end

    it "should second attempt to render a local partial by the block's name when blocks.use is called" do
      @view.expects(:capture).with(:value1 => 1, :value2 => 2).never
      @view.expects(:render).with("some_block", :value1 => 1, :value2 => 2).once
      @view.expects(:render).with("blocks/some_block", :value1 => 1, :value2 => 2).never
      @builder.use :some_block, :value1 => 1, :value2 => 2
    end

    it "should third attempt to render a global partial by the block's name when blocks.use is called" do
      @view.expects(:capture).with(:value1 => 1, :value2 => 2).never
      @view.expects(:render).with("some_block", :value1 => 1, :value2 => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @view.expects(:render).with("blocks/some_block", :value1 => 1, :value2 => 2).once
      @builder.use :some_block, :value1 => 1, :value2 => 2
    end

    it "should fourth attempt to render a default block when blocks.use is called" do
      block = Proc.new {|options|}
      @view.expects(:render).with("some_block", :value1 => 1, :value2 => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @view.expects(:render).with("blocks/some_block", :value1 => 1, :value2 => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @view.expects(:capture).with(:value1 => 1, :value2 => 2)
      @builder.use :some_block, :value1 => 1, :value2 => 2, &block
    end

    it "should not attempt to render a partial if BuildingBlocks::USE_PARTIALS is set to false" do
      BuildingBlocks.send(:remove_const, "USE_PARTIALS")
      BuildingBlocks.const_set("USE_PARTIALS", false)
      block = Proc.new {|options|}
      @view.expects(:render).with("some_block", :value1 => 1, :value2 => 2).never
      @view.expects(:render).with("blocks/some_block", :value1 => 1, :value2 => 2).never
      @view.expects(:capture).with(:value1 => 1, :value2 => 2)
      @builder.use :some_block, :value1 => 1, :value2 => 2, &block
      BuildingBlocks.send(:remove_const, "USE_PARTIALS")
      BuildingBlocks.const_set("USE_PARTIALS", true)
    end

    it "should override hash options for a block by merging the runtime options the define default options into the queue level options into the global options" do
      block = Proc.new {|options|}
      @builder.global_options.merge!(:param1 => "global level", :param2 => "global level", :param3 => "global level", :param4 => "global level")
      @builder.queue(:my_before_block, :param1 => "queue level", :param2 => "queue level")
      @builder.define(:my_before_block, :param1 => "define level", :param2 => "define level", :param3 => "define level", &block)
      block_container = @builder.queued_blocks.first
      @view.expects(:capture).with(:param4 => 'global level', :param1 => 'use level', :param2 => 'queue level', :param3 => 'define level')
      @builder.use block_container, :param1 => "use level"
    end

    it "should render the contents of a defined block when that block is used" do
      block = Proc.new {}
      @view.expects(:capture).with(nil).returns("rendered content")
      @builder.define :some_block, &block
      buffer = @builder.use :some_block
      buffer.should eql "rendered content"
    end
  end

  describe "use method - before blocks" do
    before :each do
      @builder.expects(:render_block).at_least_once
      @builder.expects(:render_after_blocks).at_least_once
    end

    it "should render before blocks when using a block" do
      block = Proc.new {|value1, value2, options|}
      @builder.before("my_before_block", &block)
      @view.expects(:capture).with(1, 2, :value3 => 3, :value4 => 4)
      @builder.use :my_before_block, 1, 2, :value3 => 3, :value4 => 4
    end

    it "should try and render a before block as a local partial if no before blocks are specified" do
      block = Proc.new {}
      @view.expects(:capture).never
      @view.expects(:render).with("before_my_before_block", :value1 => 1, :value2 => 2).once
      @view.expects(:render).with("blocks/before_my_before_block", :value1 => 1, :value2 => 2).never
      @builder.use :my_before_block, :value1 => 1, :value2 => 2
    end

    it "should try and render a before block as a global partial if no after blocks are specified and the local partial does not exist" do
      block = Proc.new {}
      @view.expects(:capture).never
      @view.expects(:render).with("before_my_before_block", :value1 => 1, :value2 => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @view.expects(:render).with("blocks/before_my_before_block", :value1 => 1, :value2 => 2).once
      @builder.use :my_before_block, :value1 => 1, :value2 => 2
    end

    it "should not attempt to render a before block as a partial if BuildingBlocks::USE_PARTIALS is set to false" do
      BuildingBlocks.send(:remove_const, "USE_PARTIALS")
      BuildingBlocks.const_set("USE_PARTIALS", false)
      block = Proc.new {}
      @view.expects(:capture).never
      @view.expects(:render).with("before_my_before_block", :value1 => 1, :value2 => 2).never
      @view.expects(:render).with("blocks/before_my_before_block", :value1 => 1, :value2 => 2).never
      @builder.use :my_before_block, :value1 => 1, :value2 => 2
      BuildingBlocks.send(:remove_const, "USE_PARTIALS")
      BuildingBlocks.const_set("USE_PARTIALS", true)
    end

    it "should not attempt to render a before block as a partial if BuildingBlocks::USE_PARTIALS_FOR_BEFORE_AND_AFTER_HOOKS is set to false" do
      BuildingBlocks.send(:remove_const, "USE_PARTIALS_FOR_BEFORE_AND_AFTER_HOOKS")
      BuildingBlocks.const_set("USE_PARTIALS_FOR_BEFORE_AND_AFTER_HOOKS", false)
      block = Proc.new {}
      @view.expects(:capture).never
      @view.expects(:render).with("before_my_before_block", :value1 => 1, :value2 => 2).never
      @view.expects(:render).with("blocks/before_my_before_block", :value1 => 1, :value2 => 2).never
      @builder.use :my_before_block, :value1 => 1, :value2 => 2
      BuildingBlocks.send(:remove_const, "USE_PARTIALS_FOR_BEFORE_AND_AFTER_HOOKS")
      BuildingBlocks.const_set("USE_PARTIALS_FOR_BEFORE_AND_AFTER_HOOKS", true)
    end

    it "should override hash options for before blocks by merging the runtime options into the before block options into the block options into the global options" do
      block = Proc.new {|options|}
      @builder.global_options.merge!(:param1 => "global level", :param2 => "global level", :param3 => "global level", :param4 => "global level")
      @builder.define(:my_before_block, :param1 => "block level", :param2 => "block level", :param3 => "block level", &block)
      @builder.before(:my_before_block, :param1 => "before block level", :param2 => "before block level", &block)
      @view.expects(:capture).with(:param4 => 'global level', :param1 => 'top level', :param2 => 'before block level', :param3 => 'block level')
      @builder.use :my_before_block, :param1 => "top level"
    end
  end
  
  describe "use method - after blocks" do
    before :each do
      @builder.expects(:render_block).at_least_once
      @builder.expects(:render_before_blocks).at_least_once
    end

    it "should render after blocks when using a block" do
      block = Proc.new {|value1, value2, options|}
      @builder.after("my_after_block", &block)
      @view.expects(:capture).with(1, 2, :value3 => 3, :value4 => 4)
      @builder.use :my_after_block, 1, 2, :value3 => 3, :value4 => 4
    end

    it "should try and render a after block as a local partial if no after blocks are specified" do
      block = Proc.new {}
      @view.expects(:capture).never
      @view.expects(:render).with("after_my_after_block", :value1 => 1, :value2 => 2).once
      @view.expects(:render).with("blocks/after_my_after_block", :value1 => 1, :value2 => 2).never
      @builder.use :my_after_block, :value1 => 1, :value2 => 2
    end

    it "should try and render a after block as a global partial if no after blocks are specified and the local partial does not exist" do
      block = Proc.new {}
      @view.expects(:capture).never
      @view.expects(:render).with("after_my_after_block", :value1 => 1, :value2 => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @view.expects(:render).with("blocks/after_my_after_block", :value1 => 1, :value2 => 2).once
      @builder.use :my_after_block, :value1 => 1, :value2 => 2
    end

    it "should not attempt to render a after block as a partial if BuildingBlocks::USE_PARTIALS is set to false" do
      BuildingBlocks.send(:remove_const, "USE_PARTIALS")
      BuildingBlocks.const_set("USE_PARTIALS", false)
      block = Proc.new {}
      @view.expects(:capture).never
      @view.expects(:render).with("after_my_after_block", :value1 => 1, :value2 => 2).never
      @view.expects(:render).with("blocks/after_my_after_block", :value1 => 1, :value2 => 2).never
      @builder.use :my_after_block, :value1 => 1, :value2 => 2
      BuildingBlocks.send(:remove_const, "USE_PARTIALS")
      BuildingBlocks.const_set("USE_PARTIALS", true)
    end

    it "should not attempt to render a after block as a partial if BuildingBlocks::USE_PARTIALS_FOR_BEFORE_AND_AFTER_HOOKS is set to false" do
      BuildingBlocks.send(:remove_const, "USE_PARTIALS_FOR_BEFORE_AND_AFTER_HOOKS")
      BuildingBlocks.const_set("USE_PARTIALS_FOR_BEFORE_AND_AFTER_HOOKS", false)
      block = Proc.new {}
      @view.expects(:capture).never
      @view.expects(:render).with("after_my_after_block", :value1 => 1, :value2 => 2).never
      @view.expects(:render).with("blocks/after_my_after_block", :value1 => 1, :value2 => 2).never
      @builder.use :my_after_block, :value1 => 1, :value2 => 2
      BuildingBlocks.send(:remove_const, "USE_PARTIALS_FOR_BEFORE_AND_AFTER_HOOKS")
      BuildingBlocks.const_set("USE_PARTIALS_FOR_BEFORE_AND_AFTER_HOOKS", true)
    end

    it "should override hash options for after blocks by merging the runtime options into the after block options into the block options into the global options" do
      block = Proc.new {|options|}
      @builder.global_options.merge!(:param1 => "global level", :param2 => "global level", :param3 => "global level", :param4 => "global level")
      @builder.define(:my_after_block, :param1 => "block level", :param2 => "block level", :param3 => "block level", &block)
      @builder.after(:my_after_block, :param1 => "after block level", :param2 => "after block level", &block)
      @view.expects(:capture).with(:param4 => 'global level', :param1 => 'top level', :param2 => 'after block level', :param3 => 'block level')
      @builder.use :my_after_block, :param1 => "top level"
    end
  end

  describe "method_missing method" do
    it "should start a new block group if a method is missing" do
      @builder.some_method
      queued_blocks = @builder.block_groups[:some_method]
      queued_blocks.should eql []
    end

    it "should add items to a queue when a new block group is started" do
      @builder.some_method do
        @builder.queue :myblock1
        @builder.queue :myblock2
      end
      @builder.some_method2 do
        @builder.queue :myblock3
      end
      queued_blocks = @builder.block_groups[:some_method]
      queued_blocks.length.should eql 2
      queued_blocks.first.name.should eql :myblock1
      queued_blocks.second.name.should eql :myblock2
      queued_blocks = @builder.block_groups[:some_method2]
      queued_blocks.length.should eql 1
      queued_blocks.first.name.should eql :myblock3
      @builder.queued_blocks.should eql []
    end
  end
end