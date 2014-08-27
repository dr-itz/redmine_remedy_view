require File.expand_path('../../test_helper', __FILE__)

class RemedyViewControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles

  setup do
    @request.session[:user_id] = 2
    Role.find(1).add_permission! :remedy_view_view
    Project.find(1).enabled_module_names = [:remedy_view]
  end

  test "should get index" do
    get :index, :project_id => 1

    assert_response :success
    assert_template 'index'
  end

  test "should deny index" do
    @request.session[:user_id] = 3
    get :index, :project_id => 1

    assert_response 403
  end
end
