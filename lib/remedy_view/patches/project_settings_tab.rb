require_dependency 'projects_helper'

module RemedyViewProjectsHelperPatch
  def self.included base
    base.send :include, RemedyViewProjectsHelperMethods
    base.class_eval do
      alias_method_chain :project_settings_tabs, :remedy_view
    end
  end
end

module RemedyViewProjectsHelperMethods
  def project_settings_tabs_with_remedy_view
    tabs = project_settings_tabs_without_remedy_view
    tab = {
      :name => 'remedy_view',
      :controller => 'remedy_view_config', :action => :show,
      :partial => 'remedy_view_config/show', :label => :label_remedy_view_menu_main}
    tabs << tab if User.current.allowed_to?(tab, @project)
    tabs
  end
end

ProjectsHelper.send(:include, RemedyViewProjectsHelperPatch)
