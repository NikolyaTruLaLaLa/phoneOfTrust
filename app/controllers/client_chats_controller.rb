class ClientChatsController < ApplicationController
  include ChatActions
  include VisitorCreateAuthToken
  include VisitorAuth

  skip_before_action :check_is_this_client_chat?, only: [ :create, :send_typing ]


  def create
    retries = 3
    retries.times do |attempt|
      token = SecureRandom.urlsafe_base64(10)
      # token = "aaaaaaaaaa"
      @chat = Chat.new(status: "waiting", visitors_token: token, visitors_init_token: session[:current_user_id])

      if @chat.save

        Turbo::StreamsChannel.broadcast_append_to(
          "admin_chats_list",
          target: "waiting_chats_list",
          partial: "admin/admin_chats/chat",
          locals: { chat: @chat }
        )

        redirect_to path_chat and return
      end

      Rails.logger.warn "Colission (programm-level) on creating chat token, attempt #{attempt}"
    end

    flash[:alert] = "Sorry, we couldn't create a chat for you. Please try again later."
    redirect_to path_fallback
  end


  def send_typing
    @chat = Chat.find_by(visitors_token: typing_params[:visitors_token])

    print(current_user_id)
    print(@chat[:visitors_init_token])
    if @chat && current_user_id == @chat[:visitors_init_token]
      print()
      print()
      print(typing_params[:content])
      print()
      print()

      Turbo::StreamsChannel.broadcast_replace_to(
        "chat_#{@chat.visitors_token}_admin",
        target: "typing_visitor",
        partial: "admin/admin_chats/typing",
        locals: { content: typing_params[:content] }
      )

      head :ok
    else
      head :forbidden
    end
  end

  private

  def path_fallback
    root_path
  end

  def path_chat
    chat_path(token: @chat.visitors_token)
  end

  def path_after_end_chat
    root_path
  end

  def typing_params
    params.require(:text).permit(:visitors_token, :content)
  end
end
