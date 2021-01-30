require 'sidekiq/web'
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :apps, param: :token, except: %i[update destroy] do
    resources :chats, param: :number, except: %i[update destroy] do
      resources :messages, param: :number, except: %i[update destroy] do
        get :search, on: :collection
      end
    end
  end
  mount Sidekiq::Web => '/sidekiq/jobs'
end
