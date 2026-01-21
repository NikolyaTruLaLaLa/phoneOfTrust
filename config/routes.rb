Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index"
  
  # Клиентские маршруты (ClientChatsController)
  # Создание чата - только у клиента
  post "/chats", to: "client_chats#create"
  
  # Просмотр и действия с чатом
  get "/chat/:token", to: "client_chats#show_chat", as: :chat
  post "/chat/:token/messages", to: "client_chats#send_message", as: :chat_messages
  post "/chat/:token/end", to: "client_chats#end_chat", as: :end_chat
  
  # Админские маршруты (AdminChatsController)
  # Главная админ-страница
  get "/admin", to: "admin/admin_chats#index", as: :admin
  
  # Работа с конкретным чатом
  get "/admin/chat/:token", to: "admin/admin_chats#show_chat", as: :admin_chat
  post "/admin/chat/:token/messages", to: "admin/admin_chats#send_message", as: :admin_chat_messages
  post "/admin/chat/:token/end", to: "admin/admin_chats#end_chat", as: :admin_end_chat

end