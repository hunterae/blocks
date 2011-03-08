require 'spec_helper'

describe HomeController do  
  render_views
  
  it "should render with the :header, :footer, :includes, :javascripts, and :stylesheets global blocks" do
    get :index
  
    response.should have_selector("h2:nth(1)") do |response|
      response.should contain("Default Header")
    end
    
    response.should have_selector("h2:nth(2)") do |response|
      response.should contain("Home Page")
    end
    
    response.should have_selector("h2:nth(3)") do |response|
      response.should contain("Default Footer")
    end
    
    response.should_not have_selector("h2:nth(4)")
    
    response.should have_selector("link:nth(1)", :href => "/stylesheets/stylesheet1.css")
    response.should have_selector("link:nth(2)", :href => "/stylesheets/stylesheet2.css")
    response.should_not have_selector("link:nth(3)")
    
    response.should have_selector("script:nth(1)", :src => "/javascripts/javascript1.js")
    response.should have_selector("script:nth(2)", :src => "/javascripts/javascript2.js")
    response.should_not have_selector("script:nth(3)")
  end
end
