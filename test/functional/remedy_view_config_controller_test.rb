require File.expand_path('../../test_helper', __FILE__)

class RemedyViewConfigControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles
  plugin_fixtures :remedy_filters

  setup do
    @request.session[:user_id] = 2
    Role.find(1).add_permission! :remedy_view_view
    Role.find(1).add_permission! :remedy_view_admin
    Project.find(1).enabled_module_names = [:remedy_view]
  end

  test "should create new filter" do
    assert_difference('RemedyFilter.count') do
      post :create, :project_id => 1, :remedy_filter => {
        :title => 'Test title',
        :group => 'Test group',
        :contract_number => 'Test contrace'
      }
    end
    assert_redirected_to settings_project_path(Project.find(1), 'remedy_view')
  end

  test "should create new filter XHR" do
    assert_difference('RemedyFilter.count') do
      xhr :post, :create, :project_id => 1, :remedy_filter => {
        :title => 'Test title',
        :group => 'Test group',
        :contract_number => 'Test contrace'
      }
    end
    assert_response :success
    assert_template 'show'
  end

  test "should delete filter" do
    assert_difference('RemedyFilter.count', -1) do
      delete :destroy, :project_id => 1, :id => 7
    end
    assert_redirected_to settings_project_path(Project.find(1), 'remedy_view')
  end

  test "should delete filter XHR" do
    assert_difference('RemedyFilter.count', -1) do
      xhr :delete, :destroy, :project_id => 1, :id => 7
    end
    assert_response :success
    assert_template 'show'
  end
end
