Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :companies, only: [:index, :show, :create] do
        resources :collaborators, shallow: true
      end
    end
  end
end
