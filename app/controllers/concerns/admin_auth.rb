module AdminAuth
  extend ActiveSupport::Concern

   LIFE_OF_AUTH = 12  # hours

  included do
    layout "admin"
    before_action :authenticate_administrator!
    helper_method :current_administrator, :administrator_signed_in?
  end

  private
  
  def authenticate_administrator!
    unless current_administrator
      redirect_to admin_login_path,
                  alert: "Требуется авторизация администратора"
    end
  end

  def current_administrator
    if session[:administrator_expires_at] && session[:administrator_expires_at] > Time.current
      @current_administrator ||= Administrator.find_by(id: session[:administrator_id])
    else
      reset_administrator_session
      nil
    end
  end

  def administrator_signed_in?
    current_administrator.present?
  end

  def sign_in_administrator(administrator)
    session[:administrator_id] = administrator.id
    session[:administrator_expires_at] = LIFE_OF_AUTH.hours.from_now
    @current_administrator = administrator
  end

  def sign_out_administrator
    reset_administrator_session
  end

  def reset_administrator_session
    session.delete(:administrator_id)
    session.delete(:administrator_expires_at)
    @current_administrator = nil
  end

end
