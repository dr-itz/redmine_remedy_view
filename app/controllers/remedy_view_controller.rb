class RemedyViewController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id
  before_filter :authorize

  helper :watchers

  def index
    @ticket_groups = []
    RemedyFilter.project_filters(@project).each do |filter|
      @ticket_groups << {
        :filter => filter,
        :tickets => RemedyTicket.by_remedy_filter(filter).open().sorted()
      }
    end
  end

  def show
    @ticket = RemedyTicket.find(params[:id], include: :issues)
    @allowed_projects = Project.allowed_to(User.current, :add_issues)
  end

  def new_issue
    @ticket = RemedyTicket.find(params[:id])

    # need to override @project for the issue to be created in the right project
    @project = Project.find(params[:issue][:project_id])

    # mostly from IssuesController#build_new_issue_from_params
    @issue = Issue.new
    @issue.project = @project
    @issue.author = User.current
    @issue.subject = @ticket.short_description
    @issue.tracker = @project.trackers.find(:first)
    @issue.start_date = Date.today if Setting.default_issue_start_date_to_creation_date?

    @priorities = IssuePriority.active
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current, @issue.new_record?)
    @available_watchers = @issue.watcher_users
    if @issue.project.users.count <= 20
      @available_watchers = (@available_watchers + @issue.project.users.sort).uniq
    end
  end
end
