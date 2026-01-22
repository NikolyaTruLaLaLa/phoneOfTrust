class BaseChatsController < ApplicationController
  # RUD from CRUD chat contoroller
  # for daughters is need to implement methods:
  # - path_fallback
  # - path_chat
  # - path_after_end_chat

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

      # redirect_to path_chat and return
    else
      flash[:alert] = "Не удалось отправить сообщение"
      redirect_to path_chat and return
    end
  end

  def end_chat
    # strong params??????
    @chat = Chat.find_by(visitors_token: params[:token])
    @chat.update(status: "ended", ended_at: Time.now)

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
    # chat_path(token: @chat.visitors_token)
    raise NotImplementedError, "#{self.class} должен реализовать метод #{__method__}"
  end

  def path_after_end_chat
    raise NotImplementedError, "#{self.class} должен реализовать метод #{__method__}"
  end
end
