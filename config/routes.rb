Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :forecasts, only: [:index] do
    collection do
      get :search
    end
  end

  root "forecasts#index"
end
