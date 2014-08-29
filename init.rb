require_dependency 'remedy_view/patches/project_settings_tab'

Redmine::Plugin.register :redmine_remedy_view do
  name 'Remedy View'
  author 'Daniel Ritz'
  description 'View Remedy AR tickets'
  version '0.0.1'
  url 'https://github.com/dr-itz/redmine_remedy_view '
  author_url 'https://github.com/dr-itz/'
  requires_redmine '2.2.0'

  project_module :remedy_view do
    permission :remedy_view_view, {
      :remedy_view => [:index, :show, :new, :create, :edit, :update, :destroy]
    }
    permission :remedy_view_config, {
      :remedy_view_config => [:show, :update]
    }
  end

  menu :project_menu, :remedy_view,
    { :controller => 'remedy_view', :action => 'index' },
    :caption => :label_remedy_view_menu_main, :param => :project_id
end
