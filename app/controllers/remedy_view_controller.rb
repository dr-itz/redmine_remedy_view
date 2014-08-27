class RemedyViewController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id, :authorize

  def index
  end

  def show
  end
end
