require File.expand_path('../../test_helper', __FILE__)

class RemedyViewControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles
  plugin_fixtures :remedy_filters, :remedy_tickets

  setup do
    @request.session[:user_id] = 2
    Role.find(1).add_permission! :remedy_view_view
    Project.find(1).enabled_module_names = [:remedy_view]
  end

  test "should get index" do
    get :index, :project_id => 1

    assert_response :success
    assert_template 'index'

    ticket_groups = assigns(:ticket_groups)
    assert_not_nil ticket_groups
    assert_equal 1, ticket_groups.length
    assert_equal RemedyFilter.find(7), ticket_groups[0][:filter]
    assert_equal 1, ticket_groups[0][:tickets].length
    assert_equal RemedyTicket.find_by_remedy_id("1-1234567"), ticket_groups[0][:tickets][0]
  end

  test "should deny index" do
    @request.session[:user_id] = 3
    get :index, :project_id => 1

    assert_response 403
  end

  test "should show ticket" do
    get :show, :project_id => 1, :id => 1

    assert_response :success
    assert_template 'show'
    assert_equal RemedyTicket.find(1), assigns(:ticket)
  end
end
