require File.dirname(__FILE__) + '/../../test_helper'

class RoutingRemedyViewTest < ActionDispatch::IntegrationTest
  def test_remedy_view_scoped_under_project
    assert_routing(
        { :method => 'get', :path => "/projects/foo/remedy" },
        { :controller => 'remedy_view', :action => 'index',
          :project_id => 'foo' })
  end
end
