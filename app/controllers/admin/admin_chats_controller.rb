module Admin
  class AdminChatsController < BaseChatsController
    def index
      @chats = Chat.all
    end

    def show_chat
      super

      return if @chat.nil?

      if @chat[:status] == "waiting"
        @chat.update(status: "active")
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
