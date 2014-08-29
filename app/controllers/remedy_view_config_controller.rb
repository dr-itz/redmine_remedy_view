class RemedyViewConfigController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id, :authorize

  def update
    #FIXME

    flash[:notice] = l(:notice_successful_update)
    redirect_to :controller => 'projects',
      :action => "settings", :id => @project, :tab => 'remedy_view'
  end
end
