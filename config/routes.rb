# Plugin's routes
match 'projects/:project_id/remedy',
  :to => 'remedy_view#index'

delete '/projects/:project_id/remedy/settings/filter/:id',
  :to => 'remedy_view_config#destroy',
  :as => 'remedy_filter'

post '/projects/:project_id/remedy/settings/filter',
  :to => 'remedy_view_config#create',
  :as => 'project_remedy_filters'
