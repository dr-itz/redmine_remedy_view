require File.expand_path('../../test_helper', __FILE__)

class RemedyViewControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :workflows,
           :time_entries

  plugin_fixtures :remedy_filters, :remedy_tickets, :remedy_ticket_issues

  setup do
    User.current = nil
    @request.session[:user_id] = 2
    Role.find(1).add_permission! :remedy_view_view
    EnabledModule.create!(:project_id => 1, :name => 'remedy_view')
  end

  test "should get index" do
    get :index, :project_id => 1

    assert_response :success
    assert_template 'index'

    ticket_groups = assigns(:ticket_groups)
    assert_not_nil ticket_groups
    assert_equal 1, ticket_groups.length
    assert_equal RemedyFilter.find(7), ticket_groups[0][:filter]
    assert_equal 2, ticket_groups[0][:tickets].length
    assert_equal RemedyTicket.find_by_remedy_id("1-1234567"), ticket_groups[0][:tickets][0]
    assert_equal RemedyTicket.find_by_remedy_id("1-1234575"), ticket_groups[0][:tickets][1]
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
    assert_equal Project.allowed_to(User.find(2), :add_issues), assigns(:allowed_projects)
  end

  test "should show related redmine issue" do
    get :show, :project_id => 1, :id => 1

    assert_response :success
    assert_template 'show'
    assert_equal RemedyTicket.find(1), assigns(:ticket)
    assert_select '#issue-4'
  end

  test "should show new issue form" do
    xhr :post, :new_issue, :project_id => 1, :id => 1, :issue => { :project_id => 2 }

    assert_response :success
    assert_template 'new_issue'

    assert_equal Project.find(2), assigns(:project)
    issue = assigns(:issue)
    assert_equal issue.subject, RemedyTicket.find(1).short_description
    assert_equal issue.author, User.find(2)

    assert_equal 1, issue.remedy_ticket_issues.length
    assert_equal 1, issue.remedy_ticket_issues.first.project_id
    assert_equal 1, issue.remedy_ticket_issues.first.remedy_ticket_id

    assert_include 'issue_remedy_ticket_issues_attributes_0_project_id', response.body
  end
end
