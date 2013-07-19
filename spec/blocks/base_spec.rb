require "spec_helper"

describe Blocks::Base do
  before :each do
    @view = ActionView::Base.new
    @builder = Blocks::Base.new(@view)
  end

  it "should be able change the default global partials directory" do
    Blocks.template_folder = "shared"
    Blocks.use_partials = true
    @builder = Blocks::Base.new(@view)
    @builder.expects(:render_before_blocks).at_least_once
    @builder.expects(:render_after_blocks).at_least_once
    @view.expects(:capture).with(:value1 => 1, :value2 => 2).never
    @view.expects(:render).with("some_block", :value1 => 1, :value2 => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
    @view.expects(:render).with("shared/some_block", :value1 => 1, :value2 => 2).once
    @builder.render :some_block, :value1 => 1, :value2 => 2
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

    it "should queue blocks as Blocks::Container objects" do
      @builder.queue :test_block, :a => 1, :b => 2, :c => 3
      container = @builder.queued_blocks.first
      container.should be_a(Blocks::Container)
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

  describe "render_template method" do
    it "should attempt to render a partial specified as the :template parameter" do
      view = mock()
      builder = Blocks::Base.new(view)
      view.expects(:render).with{ |template, options| template == "my_template"}
      builder.render_template("my_template")
    end

    it "should set all of the global options as local variables to the partial it renders" do
      view = mock()
      builder = Blocks::Base.new(view)
      view.expects(:render).with { |template, options| template == 'some_template' && options[:blocks] == builder }
      builder.render_template("some_template")
    end

    it "should capture the data of a block if a block has been specified" do
      block = Proc.new { |options| "my captured block" }
      builder = Blocks::Base.new(@view)
      @view.expects(:render).with { |tempate, options| options[:captured_block] == "my captured block" }
      builder.render_template("template", &block)
    end

    it "should by default add a variable to the partial called 'blocks' as a pointer to the Blocks::Base instance" do
      view = mock()
      builder = Blocks::Base.new(view)
      view.expects(:render).with { |template, options| options[:blocks] == builder }
      builder.render_template("some_template")
    end

    it "should allow the user to override the local variable passed to the partial as a pointer to the Blocks::Base instance" do
      view = mock()
      builder = Blocks::Base.new(view, :variable => "my_variable")
      view.expects(:render).with { |template, options| options[:blocks].should be_nil }
      builder.render_template("some_template")
    end
  end

  describe "before method" do
    it "should be aliased with prepend" do
      block = Proc.new { |options| }
      @builder.prepend :some_block, &block
      @builder.blocks[:before_some_block].should be_present
    end

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

  describe "after method" do
    it "should be aliased with append and for" do
      block = Proc.new { |options| }
      @builder.append :some_block, &block
      @builder.blocks[:after_some_block].should be_present

      block = Proc.new { |options| }
      @builder.for :some_block, &block
      @builder.blocks[:after_some_block].should be_present
    end

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

  describe "render method" do
    it "should alias the render method as use" do
      block = Proc.new {"output"}
      @builder.define :some_block, &block
      @builder.use(:some_block).should eql "output"
    end

    it "should be able to use a defined block by its name" do
      block = Proc.new {"output"}
      @builder.define :some_block, &block
      @builder.render(:some_block).should eql "output"
    end

    it "should automatically pass in an options hash to a defined block that takes one paramter when that block is used" do
      block = Proc.new {|options| "Options are #{options.inspect}"}
      @builder.define :some_block, &block
      @builder.render(:some_block).should eql "Options are {}"
    end

    it "should be able to use a defined block by its name and pass in runtime arguments as a hash" do
      block = Proc.new do |options|
        print_hash(options)
      end
      @builder.define :some_block, &block
      @builder.render(:some_block, :param1 => 1, :param2 => "value2").should eql print_hash(:param1 => 1, :param2 => "value2")
    end

    it "should be able to use a defined block by its name and pass in runtime arguments one by one" do
      block = Proc.new do |first_param, second_param, options|
        "first_param: #{first_param}, second_param: #{second_param}, #{print_hash options}"
      end
      @builder.define :some_block, &block
      @builder.render(:some_block, 3, 4, :param1 => 1, :param2 => "value2").should eql("first_param: 3, second_param: 4, #{print_hash(:param1 => 1, :param2 => "value2")}")
    end

    it "should match up the number of arguments to a defined block with the parameters passed when a block is used" do
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
      @builder.render(:some_block, 3, 4, :param1 => 1, :param2 => "value2").should eql("first_param: 3, second_param: 4, #{print_hash(:param1 => 1, :param2 => "value2")}")
    end

    it "should not render anything if using a block that has been defined" do
      @builder.use_partials = true
      @view.expects(:capture).never
      @view.expects(:render).with("some_block", {}).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @view.expects(:render).with("blocks/some_block", {}).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @builder.render :some_block
    end

    it "should first attempt to capture a block's contents when blocks.render is called" do
      block = Proc.new {|options|}
      @view.expects(:capture).with(:value1 => 1, :value2 => 2)
      @view.expects(:render).with("some_block", :value1 => 1, :value2 => 2).never
      @view.expects(:render).with("blocks/some_block", :value1 => 1, :value2 => 2).never
      @builder.define :some_block, &block
      @builder.render :some_block, :value1 => 1, :value2 => 2
    end

    it "should second attempt to render a local partial by the block's name when blocks.render is called" do
      @builder.use_partials = true
      @view.expects(:capture).with(:value1 => 1, :value2 => 2).never
      @view.expects(:render).with("some_block", :value1 => 1, :value2 => 2).once
      @view.expects(:render).with("blocks/some_block", :value1 => 1, :value2 => 2).never
      @builder.render :some_block, :value1 => 1, :value2 => 2
    end

    it "should third attempt to render a global partial by the block's name when blocks.render is called" do
      @builder.use_partials = true
      @view.expects(:capture).with(:value1 => 1, :value2 => 2).never
      @view.expects(:render).with("some_block", :value1 => 1, :value2 => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @view.expects(:render).with("blocks/some_block", :value1 => 1, :value2 => 2).once
      @builder.render :some_block, :value1 => 1, :value2 => 2
    end

    it "should fourth attempt to render a default block when blocks.render is called" do
      block = Proc.new {|options|}
      @builder.use_partials = true
      @view.expects(:render).with("some_block", :value1 => 1, :value2 => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @view.expects(:render).with("blocks/some_block", :value1 => 1, :value2 => 2).raises(ActionView::MissingTemplate.new([],[],[],[],[]))
      @view.expects(:capture).with(:value1 => 1, :value2 => 2)
      @builder.render :some_block, :value1 => 1, :value2 => 2, &block
    end

    it "should not attempt to render a partial if use_partials is set to false" do
      @builder.use_partials = false
      block = Proc.new {|options|}
      @view.expects(:render).with("some_block", :value1 => 1, :value2 => 2).never
      @view.expects(:render).with("blocks/some_block", :value1 => 1, :value2 => 2).never
      @view.expects(:capture).with(:value1 => 1, :value2 => 2)
      @builder.render :some_block, :value1 => 1, :value2 => 2, &block
    end

    it "should not attempt to render a partial if use_partials is passed in as false as an option to Blocks::Base.new" do
      mocha_teardown
      @builder = Blocks::Base.new(@view, :use_partials => false)
      @builder.expects(:render_before_blocks).at_least_once
      @builder.expects(:render_after_blocks).at_least_once
      block = Proc.new {|options|}
      @view.expects(:render).with("some_block", :value1 => 1, :value2 => 2).never
      @view.expects(:render).with("blocks/some_block", :value1 => 1, :value2 => 2).never
      @view.expects(:capture).with(:value1 => 1, :value2 => 2)
      @builder.render :some_block, :value1 => 1, :value2 => 2, &block
    end

    it "should override hash options for a block by merging the runtime options the define default options into the queue level options into the global options" do
      block = Proc.new {|options|}
      @builder.global_options.merge!(:param1 => "global level", :param2 => "global level", :param3 => "global level", :param4 => "global level")
      @builder.queue(:my_before_block, :param1 => "queue level", :param2 => "queue level")
      @builder.define(:my_before_block, :param1 => "define level", :param2 => "define level", :param3 => "define level", &block)
      block_container = @builder.queued_blocks.first
      @view.expects(:capture).with(:param4 => 'global level', :param1 => 'use level', :param2 => 'queue level', :param3 => 'define level')
      @builder.render block_container, :param1 => "use level"
    end

    it "should render the contents of a defined block when that block is used" do
      block = Proc.new {}
      @view.expects(:capture).with(nil).returns("rendered content")
      @builder.define :some_block, &block
      buffer = @builder.render :some_block
      buffer.should eql "rendered content"
    end

    describe "with a collection passed in" do
      it "should render a block for each element of the collection with the name of the block used as the name of the element passed into the block" do
        block = Proc.new {|item, options| "output#{options[:some_block]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3]).should eql "output1 output2 output3 "
      end

      it "should render a block for each element of the collection with the 'as' option specifying the name of the element passed into the block" do
        block = Proc.new {|item, options| "output#{options[:my_block_name]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3], :as => "my_block_name").should eql "output1 output2 output3 "
      end

      it "should render a block for each element of the collection with a surrounding element if that option is specified" do
        block = Proc.new {|item, options| "output#{options[:my_block_name]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3], :surrounding_tag => "div").should eql "<div>output </div><div>output </div><div>output </div>"
      end

      it "should render a block for each element of the collection with a surrounding element and specified html options if those options are specified" do
        block = Proc.new {|item, options| "output#{options[:my_block_name]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3], :surrounding_tag => "div", :surrounding_tag_html => {:class => lambda { @view.cycle("even", "odd")}, :style => "color:red"}).should eql "<div class=\"even\" style=\"color:red\">output </div><div class=\"odd\" style=\"color:red\">output </div><div class=\"even\" style=\"color:red\">output </div>"
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

      it "should by default put surrounding elements around before and after blocks" do
        before_block = Proc.new {|item, options| "before#{options[:some_block]} "}
        @builder.before :some_block, &before_block

        after_block = Proc.new {|item, options| "after#{options[:some_block]} "}
        @builder.after :some_block, &after_block

        block = Proc.new {|item, options| "output#{options[:some_block]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3], :surrounding_tag => "div").should eql "<div>before1 output1 after1 </div><div>before2 output2 after2 </div><div>before3 output3 after3 </div>"
      end

      it "should allow the global option to be set to render before and after blocks outside of surrounding elements" do
        Blocks.surrounding_tag_surrounds_before_and_after_blocks = false
        @builder = Blocks::Base.new(@view)
        before_block = Proc.new {|item, options| "before#{options[:some_block]} "}
        @builder.before :some_block, &before_block

        after_block = Proc.new {|item, options| "after#{options[:some_block]} "}
        @builder.after :some_block, &after_block

        block = Proc.new {|item, options| "output#{options[:some_block]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3], :surrounding_tag => "div").should eql "before1 <div>output1 </div>after1 before2 <div>output2 </div>after2 before3 <div>output3 </div>after3 "
      end

      it "should allow the option to be set to render before and after blocks outside of surrounding elements to be specified when Blocks is initialized" do
        @builder = Blocks::Base.new(@view, :surrounding_tag_surrounds_before_and_after_blocks => false)
        before_block = Proc.new {|item, options| "before#{options[:some_block]} "}
        @builder.before :some_block, &before_block

        after_block = Proc.new {|item, options| "after#{options[:some_block]} "}
        @builder.after :some_block, &after_block

        block = Proc.new {|item, options| "output#{options[:some_block]} "}
        @builder.define :some_block, &block
        @builder.render(:some_block, :collection => [1,2,3], :surrounding_tag => "div").should eql "before1 <div>output1 </div>after1 before2 <div>output2 </div>after2 before3 <div>output3 </div>after3 "
      end
    end
  end

  describe "render method - before blocks" do
    before :each do
      @builder.expects(:render_block).at_least_once
      @builder.expects(:render_after_blocks).at_least_once
    end

    it "should render before blocks when using a block" do
      block = Proc.new {|value1, value2, options|}
      @builder.before("my_before_block", &block)
      @view.expects(:capture).with(1, 2, :value3 => 3, :value4 => 4)
      @builder.render :my_before_block, 1, 2, :value3 => 3, :value4 => 4
    end

    it "should override hash options for before blocks by merging the runtime options into the before block options into the block options into the global options" do
      block = Proc.new {|options|}
      @builder.global_options.merge!(:param1 => "global level", :param2 => "global level", :param3 => "global level", :param4 => "global level")
      @builder.define(:my_before_block, :param1 => "block level", :param2 => "block level", :param3 => "block level", &block)
      @builder.before(:my_before_block, :param1 => "before block level", :param2 => "before block level", &block)
      @view.expects(:capture).with(:param4 => 'global level', :param1 => 'top level', :param2 => 'before block level', :param3 => 'block level')
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
      around_block1 = Proc.new { |content_block| "<h1>#{content_block.call}</h1>" }
      around_block2 = Proc.new { |content_block| "<span style='font-size: 100px'>#{content_block.call}</span>" }
      around_block3 = Proc.new { |content_block| "<span style='color:red'>#{content_block.call}</span>" }
      @builder.define(:my_block, &my_block)
      @builder.around(:my_block, &around_block1)
      @builder.around(:my_block, &around_block2)
      @builder.around(:my_block, &around_block3)
      @builder.render(:my_block).should eql("&lt;h1&gt;&amp;lt;span style='font-size: 100px'&amp;gt;&amp;amp;lt;span style='color:red'&amp;amp;gt;test&amp;amp;lt;/span&amp;amp;gt;&amp;lt;/span&amp;gt;&lt;/h1&gt;")
    end
  end

  describe "render method - after blocks" do
    before :each do
      @builder.expects(:render_block).at_least_once
      @builder.expects(:render_before_blocks).at_least_once
    end

    it "should render after blocks when using a block" do
      block = Proc.new {|value1, value2, options|}
      @builder.after("my_after_block", &block)
      @view.expects(:capture).with(1, 2, :value3 => 3, :value4 => 4)
      @builder.render :my_after_block, 1, 2, :value3 => 3, :value4 => 4
    end

    it "should override hash options for after blocks by merging the runtime options into the after block options into the block options into the global options" do
      block = Proc.new {|options|}
      @builder.global_options.merge!(:param1 => "global level", :param2 => "global level", :param3 => "global level", :param4 => "global level")
      @builder.define(:my_after_block, :param1 => "block level", :param2 => "block level", :param3 => "block level", &block)
      @builder.after(:my_after_block, :param1 => "after block level", :param2 => "after block level", &block)
      @view.expects(:capture).with(:param4 => 'global level', :param1 => 'top level', :param2 => 'after block level', :param3 => 'block level')
      @builder.render :my_after_block, :param1 => "top level"
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

  describe "evaluated_procs method" do
    it "should evaluate any proc options" do
      proc1 = lambda {@view.cycle("even", "odd")}
      proc2 = lambda {@view.cycle("one", "two")}
      evaluated_procs = @builder.evaluated_procs(:class => proc1, :id => proc2, :style => "color:red")
      evaluated_procs[:class].should eql "even"
      evaluated_procs[:id].should eql "one"
      evaluated_procs[:style].should eql "color:red"
    end

    it "should pass any additional arguments to evaluated procs" do
      proc1 = lambda { |param1, param2| "user_#{param1}_#{param2}"}
      evaluated_procs = @builder.evaluated_procs({:class => proc1}, 1, 2)
      evaluated_procs[:class].should eql "user_1_2"
    end
  end

  describe "evaluated_proc method" do
    it "should evaluate a proc" do
      proc = lambda {@view.cycle("even", "odd")}
      @builder.evaluated_proc(proc).should eql "even"
      @builder.evaluated_proc(proc).should eql "odd"
      @builder.evaluated_proc(proc).should eql "even"
    end

    it "should just return the value if it is not a proc" do
      @builder.evaluated_proc("1234").should eql "1234"
    end

    it "should return nil if no arguments are specified" do
      @builder.evaluated_proc.should be_nil
    end

    it "should treat the first argument as the potential proc to evaluate" do
      @builder.evaluated_proc(1, 2, 3).should eql 1
    end

    it "should pass any additional arguments to the evaluated proc" do
      proc1 = lambda { |param1, param2| "user_#{param1}_#{param2}"}
      @builder.evaluated_proc(proc1, 1, 2).should eql "user_1_2"
    end
  end
end