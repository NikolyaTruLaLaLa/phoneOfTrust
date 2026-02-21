Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"

  # Клиентские маршруты (ClientChatsController)
  # Создание чата - только у клиента
  post "/chats", to: "client_chats#create"

  # Просмотр и действия с чатом
  get "/chat/:token", to: "client_chats#show_chat", as: :chat
  post "/chat/:token/messages", to: "client_chats#send_message", as: :chat_messages
  post "/chat/:token/end", to: "client_chats#end_chat", as: :end_chat

  get "login", to: "sessions#new", as: :login
  get "initialize", to: "sessions#create", as: :initialize_visitor
  delete "logout", to: "sessions#destroy", as: :logout

  post "send_typing", to: "client_chats#send_typing"

  namespace :admin do
    get "login", to: "sessions#new", as: :login
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy", as: :logout

    # Админские маршруты (AdminChatsController)
    # Главная админ-страница
    root to: "admin_chats#index"

    # Работа с конкретным чатом
    get "chat/:token", to: "admin_chats#show_chat", as: :chat
    post "chat/:token/messages", to: "admin_chats#send_message", as: :chat_messages
    post "chat/:token/end", to: "admin_chats#end_chat", as: :end_chat
  end
end
