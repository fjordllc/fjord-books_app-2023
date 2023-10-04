Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :users
  root to: 'books#index'
  resources :books
  resources :users, only: %i(index show)
  resources :reports
  resources :comment

  resources :books do
    resources :comments, only: %i[create update destroy], module: :books
  end

  resources :reports do
    resources :comments, only: %i[create update destroy], module: :reports
  end
end
