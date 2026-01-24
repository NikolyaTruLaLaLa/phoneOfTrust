module ChatActions
  extend ActiveSupport::Concern

  included do
    include ActionView::RecordIdentifier
  end

  def show_chat
    # strong params??????
    @chat = Chat.find_by(visitors_token: params[:token])

    if @chat.nil?
      render plain: "Чат с токеном '#{params[:token]}' не найден", status: :not_found
      Rails.logger.warn "Chat with token '#{params[:token]}' not found"
      nil
    end
  end

  def send_message
    @chat = Chat.find_by(visitors_token: message_params[:token])

    if @chat.nil? || @chat.status != "active"
      flash[:alert] = "Чат не доступен для отправки сообщений"
      redirect_back fallback_location: path_fallback and return
    end

    @message = @chat.messages.create(
      # TODO add chechking for existing sender
      sender: message_params[:sender],
      content: message_params[:content]
    )

    if @message.save
      broadcast_messages
      # redirect_to path_chat and return
    else
      flash[:alert] = "Не удалось отправить сообщение"
      redirect_to path_chat and return
    end
  end

  def end_chat
    @chat = Chat.find_by(visitors_token: params[:token])
    @chat.update(status: "ended", ended_at: Time.now)

    broadcast_chat_ended
    redirect_to path_after_end_chat
  end

  protected
  def message_params
    params.require(:message).permit(:sender, :content, :token)
  end

  def path_fallback
    raise NotImplementedError, "#{self.class} должен реализовать метод #{__method__}"
  end

  def path_chat
    raise NotImplementedError, "#{self.class} должен реализовать метод #{__method__}"
  end

  def path_after_end_chat
    raise NotImplementedError, "#{self.class} должен реализовать метод #{__method__}"
  end

  private

  def broadcast_messages
    Turbo::StreamsChannel.broadcast_append_to(
          "chat_#{@chat.visitors_token}_admin",
          target: "messages",
          partial: "shared/message_admin",
          locals: { mes: @message })

    Turbo::StreamsChannel.broadcast_append_to(
        "chat_#{@chat.visitors_token}_visitor",
        target: "messages",
        partial: "shared/message_visitor",
        locals: { mes: @message })

    Turbo::StreamsChannel.broadcast_replace_to(
      "chat_#{@chat.visitors_token}_#{@message.sender}",
      target: "sending_form",
      partial: "shared/send_message_form",
      locals: { chat: @chat,
                current_sender: @message.sender,
                current_goal_url: @message.sender == "visitor" ? chat_messages_path(@chat.visitors_token) : admin_chat_messages_path(@chat.visitors_token) }
    )
  end

  def broadcast_chat_ended
    Turbo::StreamsChannel.broadcast_replace_to(
      "chat_#{@chat.visitors_token}_visitor",
      target: "chat-status-#{@chat.visitors_token}",
      partial: "client_chats/chat_status",
      locals: { chat: @chat }
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      "chat_#{@chat.visitors_token}_admin",
      target: "sending_form",
      partial: "admin/admin_chats/chat_status",
      locals: { chat: @chat }
    )

    Turbo::StreamsChannel.broadcast_remove_to(
      "admin_chats_list",
      target: dom_id(@chat)
    )

    Turbo::StreamsChannel.broadcast_remove_to(
      "chat_#{@chat.visitors_token}_admin",
      target: "end_chat_button"
    )

    Turbo::StreamsChannel.broadcast_remove_to(
      "chat_#{@chat.visitors_token}_visitor",
      target: "end_chat_button"
    )
  end
end
