class RemedyViewController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id, :authorize

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
    @ticket = RemedyTicket.find(params[:id])
  end
end
