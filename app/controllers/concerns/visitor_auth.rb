module VisitorAuth
  extend ActiveSupport::Concern

  included do
    before_action :check_is_this_client_chat?
  end

  def check_is_this_client_chat?
    chat = Chat.find_by(visitors_token: params[:token])

    if chat.nil? || chat.visitors_init_token != current_user_id
      flash[:alert] = "Не вы создали данный чат, поэтому вы не имеете к нему доступа. Создайте свой чат по заданной кнопке"
      redirect_to root_path
    end
  end
end
