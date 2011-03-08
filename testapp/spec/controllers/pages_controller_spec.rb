require 'spec_helper'

describe PagesController do  
  render_views
  
  it "should utilize the before and after hooks in rendering the blocks :includes, :javascripts, and :stylesheets" do
    get :javascript_and_stylesheet_include_hooks
    
    response.should have_selector("title") do |response|
      response.should contain("Default Title")
    end
  
    response.should have_selector("h2:nth(1)") do |response|
      response.should contain("Pages Controller Override of Header")
    end
    
    response.should have_selector("h2:nth(2)") do |response|
      response.should contain("Pages Controller Override of Footer")
    end
    
    response.should_not have_selector("h2:nth(3)")

    response.should have_selector("link:nth(1)", :href => "/stylesheets/first.css")
    response.should have_selector("link:nth(2)", :href => "/stylesheets/stylesheet1.css")
    response.should have_selector("link:nth(3)", :href => "/stylesheets/stylesheet2.css")
    response.should have_selector("link:nth(4)", :href => "/stylesheets/last.css")
    response.should_not have_selector("link:nth(5)")
    
    response.should have_selector("script:nth(1)", :src => "/javascripts/before-includes.js")
    response.should have_selector("script:nth(2)", :src => "/javascripts/first.js")
    response.should have_selector("script:nth(3)", :src => "/javascripts/javascript1.js")
    response.should have_selector("script:nth(4)", :src => "/javascripts/javascript2.js")
    response.should have_selector("script:nth(5)", :src => "/javascripts/last.js")
    response.should have_selector("script:nth(6)", :src => "/javascripts/after-includes.js")
    response.should_not have_selector("script:nth(7)")
  end
  
  it "should be able to override a block used within another block with an inline definition" do
    get :override_block_inside_global_block
    
    response.should have_selector("title") do |response|
      response.should contain("Default Title")
    end
  
    response.should have_selector("h2:nth(1)") do |response|
      response.should contain("Pages Controller Override of Header")
    end
    
    response.should have_selector("h2:nth(2)") do |response|
      response.should contain("Pages Controller Override of Footer")
    end
    
    response.should_not have_selector("h2:nth(3)")

    response.should have_selector("link:nth(1)", :href => "/stylesheets/first.css")
    response.should have_selector("link:nth(2)", :href => "/stylesheets/stylesheet1.css")
    response.should have_selector("link:nth(3)", :href => "/stylesheets/stylesheet2.css")
    response.should have_selector("link:nth(4)", :href => "/stylesheets/last.css")
    response.should_not have_selector("link:nth(5)")
    
    response.should have_selector("script:nth(1)", :src => "/javascripts/before-includes.js")
    response.should have_selector("script:nth(2)", :src => "/javascripts/first.js")
    response.should have_selector("script:nth(3)", :src => "/javascripts/overridden-includes.js")
    response.should have_selector("script:nth(4)", :src => "/javascripts/last.js")
    response.should have_selector("script:nth(5)", :src => "/javascripts/after-includes.js")
    response.should_not have_selector("script:nth(6)")
  end
  
  it "should be able to override a global block with a controller block" do
    get :override_global_block_with_controller_block
    
    response.should have_selector("title") do |response|
      response.should contain("Default Title")
    end
    
    response.should have_selector("h2:nth(1)") do |response|
      response.should contain("Code Before the Header1")
    end
    
    response.should have_selector("h2:nth(2)") do |response|
      response.should contain("Code Before the Header2")
    end
    
    response.should have_selector("h2:nth(3)") do |response|
      response.should contain("Pages Controller Override of Header")
    end
    
    response.should have_selector("h2:nth(4)") do |response|
      response.should contain("Code After the Header1")
    end
    
    response.should have_selector("h2:nth(5)") do |response|
      response.should contain("Code After the Header2")
    end
    
    response.should have_selector("h2:nth(6)") do |response|
      response.should contain("Code Before the Footer")
    end
    
    response.should have_selector("h2:nth(7)") do |response|
      response.should contain("Pages Controller Override of Footer")
    end
    
    response.should have_selector("h2:nth(8)") do |response|
      response.should contain("Code After the Footer")
    end
    
    response.should_not have_selector("h2:nth(9)")
  end
  
  it "should be able to override a global block with an inline block" do
    get :override_global_block_with_inline_block
    
    response.should have_selector("title") do |response|
      response.should contain("Default Title")
    end
    
    response.should have_selector("h2:nth(1)") do |response|
      response.should contain("Code Before the Header")
    end
    
    response.should have_selector("h2:nth(2)") do |response|
      response.should contain("Local Override of Header")
    end
    
    response.should have_selector("h2:nth(3)") do |response|
      response.should contain("Code After the Header")
    end
    
    response.should have_selector("h2:nth(4)") do |response|
      response.should contain("Pages Controller Override of Footer")
    end
    
    response.should_not have_selector("h2:nth(5)")
  end
  
  it "should be able to override a block that is given a default implementation in the layout by defining the block in the view" do
    get :override_inline_block_in_layout_with_inline_block
    
    response.should have_selector("title") do |response|
      response.should contain("Inline Override of Title")
    end
  end
end
