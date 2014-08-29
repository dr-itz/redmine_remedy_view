require File.dirname(__FILE__) + '/../test_helper'

class RemedyViewConfigShowTest < ActionDispatch::IntegrationTest
  fixtures :projects, :roles, :members, :member_roles, :enabled_modules

  setup do
    Role.find(1).add_permission! :remedy_view_admin

    @project = Project.find(1)
    @project.enabled_module_names = [:remedy_view]
  end

  test "should show settings" do
    log_user('jsmith', 'jsmith')
    get "/projects/1/settings/remedy_view"

    assert_response 200
    assert_select "#new_remedy_filter"
  end
end
