module VisitorCreateAuthToken
  extend ActiveSupport::Concern

  LIFE_OF_VISITOR_AUTH = 12 # hours
  TOKEN_LENGTH = 20

  included do
    before_action :authenticate_visitor!
    helper_method :current_user_id, :visitor_signed_in?
  end

  def authenticate_visitor!
    unless current_user_id
      redirect_to login_path
    end
  end

  def current_user_id
    if session[:visitor_expires_at] && session[:visitor_expires_at] > Time.current
      @current_user_id ||= session[:current_user_id]
    else
      reset_visitor_session
      nil
    end
  end

  def visitor_signed_in?
    print('LOOO')
    print(@current_user_id)
    current_user_id.present?
  end

  def sign_in_visitor
    token = SecureRandom.urlsafe_base64(TOKEN_LENGTH)
    session[:current_user_id] = token
    session[:visitor_expires_at] = LIFE_OF_VISITOR_AUTH.hours.from_now
    @current_user_id = token
  end

  def sign_out_visitor
    reset_visitor_session
  end

  def reset_visitor_session
    session.delete(:current_user_id)
    session.delete(:visitor_expires_at)
    @current_user_id = nil
  end
end