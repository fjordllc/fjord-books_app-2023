Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: "users/registrations" }
  root to: 'books#index'
  resources :books do
    scope module: :books do
      resources :comments, only: :create
    end
  end
  resources :reports do
    scope module: :reports do
      resources :comments, only: :create
    end
  end
  resources :comments, only: :destroy
  resources :users, only: %i(index show)
end
