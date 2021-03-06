class RemedyViewConfigController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id, :authorize

  def create
    @remedy_filter = RemedyFilter.new
    @remedy_filter.title = params[:remedy_filter][:title]
    @remedy_filter.group = params[:remedy_filter][:group]
    @remedy_filter.contract_number = params[:remedy_filter][:contract_number]
    @remedy_filter.project = @project

    if @remedy_filter.save
      @new_filter_id = @remedy_filter.id
      @remedy_filter = RemedyFilter.new
    end

    respond_to do |format|
      format.html { redirect_to settings_project_path(@project, 'remedy_view') }
      format.js { render :action => "show" }
    end
  end

  def destroy
    filter = RemedyFilter.find(params[:id])
    return render_403 unless @project.id == filter.project_id

    filter.destroy

    respond_to do |format|
      format.html { redirect_to settings_project_path(@project, 'remedy_view') }
      format.js { render :action => "show" }
    end
  end
end
