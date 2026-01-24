module AdminAuth
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_admin!
  end

  private

  def authenticate_admin!
    # Ваша логика проверки админа
    unless current_user&.admin?
      redirect_to admin_login_path,
                  alert: "Требуются права администратора"
    end
  end
end
