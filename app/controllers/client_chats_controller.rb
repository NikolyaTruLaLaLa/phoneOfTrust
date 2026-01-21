class ClientChatsController < BaseChatsController
  def create

    retries = 3
    retries.times do |attempt|
    
      token = SecureRandom.urlsafe_base64(10)
      #token = "aaaaaaaaaa"
      @chat = Chat.new(status: "waiting", visitors_token: token)
      
      if @chat.save
        redirect_to path_chat and return
      end

      Rails.logger.warn "Colission (programm-level) on creating chat token, attempt #{attempt}"

    end

    flash[:alert] = "Sorry, we couldn't create a chat for you. Please try again later."
    redirect_to path_fallback
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



end
