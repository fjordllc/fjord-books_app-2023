Rails.application.routes.draw do
  resources :reports
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :users
  root to: 'books#index'
  resources :books
  resources :users, only: %i(index show)

  resources :reports do
    resources :comments, only: %i[create destroy], module: :reports
  end

  resources :books do
    resources :comments, only: %i[create destroy], module: :books
  end
end
