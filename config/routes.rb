Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :users
  root to: 'books#index'
  resources :books
  resources :users, only: %i(index show)
  resources :reports
  resources :comments, only: %i(edit update destroy)

  resources :books do
    resources :comments, only: %i[create], module: :books
  end

  resources :reports do
    resources :comments, only: %i[create], module: :reports
  end
end
