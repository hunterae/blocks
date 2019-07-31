require 'spec_helper'

describe Blocks::HashWithRenderStrategy do
  subject { Blocks::HashWithRenderStrategy.new }

  context 'Initialization' do
    xit "TODO"
  end

  context '#dup' do
    xit "TODO"
  end

  context '#clone' do
    xit "TODO"
  end

  context '#reverse_merge' do
    it "should clone the original hash and add options on the new hash" do
      cloned = double(add_options: true)
      # expect(cloned).to receive(:add_options).and_return "added"
      expect(subject).to receive(:clone).and_return cloned
      expect(subject.reverse_merge(:a => 1)).to eql cloned
    end
  end

  context '#add_options' do
    xit "TODO"
  end

  context '#render_strategy_and_item' do
    xit "TODO"
  end
end