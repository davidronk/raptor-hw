Rails.application.routes.draw do
  resources :pdf_metadata

  root 'welcome#index'
end
