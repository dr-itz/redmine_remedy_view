# Plugin's routes
get 'projects/:project_id/remedy',
  :to => 'remedy_view#index',
  :as => 'remedy_tickets'

get 'projects/:project_id/remedy/:id',
  :to => 'remedy_view#show',
  :as => 'remedy_ticket'

post 'projects/:project_id/remedy/:id/new_issue',
  :to => 'remedy_view#new_issue',
  :as => 'remedy_ticket_new_issue'

delete '/projects/:project_id/remedy/settings/filter/:id',
  :to => 'remedy_view_config#destroy',
  :as => 'remedy_filter'

post '/projects/:project_id/remedy/settings/filter',
  :to => 'remedy_view_config#create',
  :as => 'project_remedy_filters'
