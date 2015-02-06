require File.expand_path('../../test_helper', __FILE__)

class RoutingTest < ActionController::IntegrationTest

  test "baselines" do
    # REST actions
    assert_routing({ :path => "/baselines/1", :method => :get }, { :controller => "baselines", :action => "show", :id => '1'})
    #assert_routing({ :path => "/projects/1/baselines/1/edit", :method => :get }, { :controller => "baselines", :action => "edit", :project_id => '1', :id => '1'})
    #assert_routing({ :path => "/projects/1/baselines/1", :method => :put }, { :controller => "baselines", :action => "update", :project_id => '1', :id => '1'})
    #assert_routing({ :path => "/projects/1/baselines", :method => :post }, { :controller => "baselines", :action => "create", :project_id => '1'})
    #assert_routing({ :path => "/projects/1/baselines", :method => :get }, { :controller => "baselines", :action => "index", :project_id => '1'})
  end

end