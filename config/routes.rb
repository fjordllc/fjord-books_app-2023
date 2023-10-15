Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :users
  resources :users, only: %i(index show)
  root to: 'books#index'
  resources :books
  resources :reports

  resources :books do
    resources :comments, only: %i[create edit update destroy], module: :books
  end

  resources :reports do
    resources :comments, only: %i[create edit update destroy], module: :reports
  end
end
