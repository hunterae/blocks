Testapp::Application.routes.draw do
  match '/', :to => 'home#index'
  match ':controller/:action'
end
