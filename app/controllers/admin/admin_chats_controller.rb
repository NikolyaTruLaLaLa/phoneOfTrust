module Admin
  class AdminChatsController < BaseChatsController
    include ActionView::RecordIdentifier

    def index
      # Заранее разделяем чаты, чтобы избежать множественных запросов where в шаблоне
      @active_chats = Chat.where(status: "active")
      @waiting_chats = Chat.where(status: "waiting")
    end

    def show_chat
      super

      return if @chat.nil?

      if @chat[:status] == "waiting"
        @chat.update(status: "active")

        Turbo::StreamsChannel.broadcast_remove_to(
          "admin_chats_list",
          target: dom_id(@chat)
        )

        Turbo::StreamsChannel.broadcast_append_to(
          "admin_chats_list",
          target: "active_chats_list",
          partial: "admin/admin_chats/chat",
          locals: { chat: @chat }
        )

        Turbo::StreamsChannel.broadcast_replace_to(
          "chat_#{@chat.visitors_token}_visitor",
          target: "chat-status-#{@chat.visitors_token}",
          partial: "client_chats/chat_status",
          locals: { chat: @chat })
      end
    end

    protected

    def path_fallback
      admin_path
    end

    def path_chat
      admin_chat_path(token: @chat.visitors_token)
    end

    def path_after_end_chat
      admin_path
    end
  end
end
