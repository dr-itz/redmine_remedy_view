# Plugin's routes
match 'projects/:project_id/remedy',
  :to => 'remedy_view#index'

put '/projects/:project_id/remedy_view/settings',
  :to => 'remedy_view_config#update',
  :as => 'remedy_view_config'
