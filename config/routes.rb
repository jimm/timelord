Timelord::Application.routes.draw do

  get 'account/login', :controller => 'account', :action => 'login'
  get 'account/logout', :controller => 'account', :action => 'logout'
  get 'account/:id/edit', :controller => 'account', :action => 'edit'
  put 'account/1', :controller => 'account', :action => 'update'

  resources :users

  resources :work_entries

  resources :codes

  resources :locations

  get '/', :controller => 'work_entries', :action => 'new'
  get 'nav', :controller => 'nav', :action => 'index'
  get 'nav/:action', :controller => 'nav'

  get 'locations/:id/codes(.:format)', :controller => 'locations', :action => 'codes'

  get 'invoice', :controller => 'invoice', :action => 'index'
  get 'invoice/preview(.:format)', :controller => 'invoice', :action => 'preview'
end
