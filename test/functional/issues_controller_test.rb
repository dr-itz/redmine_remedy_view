require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < ActionController::TestCase
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

  test "should create new issue with remedy ticket" do
    assert_difference 'Issue.count' do
      post :create, :project_id => 1, :issue => {
        :tracker_id => 3,
        :status_id => 2,
        :subject => 'This is the test_new issue for Remedy',
        :description => 'This is the description',
        :priority_id => 5,
        :remedy_ticket_issues_attributes => {
          "0" => {
            :project_id => '2',
            :remedy_ticket_id => '1'
          }
        }
      }
    end

    assert_redirected_to :controller => 'issues', :action => 'show', :id => Issue.last.id

    issue = Issue.find_by_subject('This is the test_new issue for Remedy')
    assert_not_nil issue
    assert_equal 2, issue.author_id
    assert_equal 3, issue.tracker_id
    assert_equal 2, issue.status_id

    assert_equal 1, issue.remedy_ticket_issues.length
    assert_equal 2, issue.remedy_ticket_issues.first.project_id
    assert_equal 1, issue.remedy_ticket_issues.first.remedy_ticket_id
  end

  test "should show related remedy tickets in issue" do
    get :show, :id => 4

    assert_response :success
    assert_template 'show'

    assert_select '#remedy-1-1234567'
  end
end
