require_dependency 'projects_helper'

module ProjectsHelper
  def project_settings_tabs_with_remedy_view
    tabs = project_settings_tabs_without_remedy_view
    tab = {
      :name => 'remedy_view',
      :controller => 'remedy_view_config', :action => :show,
      :partial => 'remedy_view_config/show', :label => :label_remedy_view_menu_main}
    tabs << tab if User.current.allowed_to?(tab, @project)
    tabs
  end

  alias_method_chain :project_settings_tabs, :remedy_view
end
