require "spec_helper"

describe Blocks::ProcWithArgs do
  before :each do
    @view = ActionView::Base.new
  end

  describe "call_each_hash_value method" do
    it "should evaluate any proc options" do
      proc1 = lambda {@view.cycle("even", "odd")}
      proc2 = lambda {@view.cycle("one", "two")}
      evaluated_procs = Blocks::ProcWithArgs.call_each_hash_value(:class => proc1, :id => proc2, :style => "color:red")
      evaluated_procs[:class].should eql "even"
      evaluated_procs[:id].should eql "one"
      evaluated_procs[:style].should eql "color:red"
    end

    it "should pass any additional arguments to evaluated procs" do
      proc1 = lambda { |param1, param2| "user_#{param1}_#{param2}"}
      evaluated_procs = Blocks::ProcWithArgs.call_each_hash_value({:class => proc1}, 1, 2)
      evaluated_procs[:class].should eql "user_1_2"
    end
  end

  describe "call method" do
    it "should evaluate a proc" do
      proc = lambda {@view.cycle("even", "odd")}
      Blocks::ProcWithArgs.call(proc).should eql "even"
      Blocks::ProcWithArgs.call(proc).should eql "odd"
      Blocks::ProcWithArgs.call(proc).should eql "even"
    end

    it "should just return the value if it is not a proc" do
      Blocks::ProcWithArgs.call("1234").should eql "1234"
    end

    it "should return nil if no arguments are specified" do
      Blocks::ProcWithArgs.call.should be_nil
    end

    it "should treat the first argument as the potential proc to evaluate" do
      Blocks::ProcWithArgs.call(1, 2, 3).should eql 1
    end

    it "should pass any additional arguments to the evaluated proc" do
      proc1 = lambda { |param1, param2| "user_#{param1}_#{param2}"}
      Blocks::ProcWithArgs.call(proc1, 1, 2).should eql "user_1_2"
    end
  end
end