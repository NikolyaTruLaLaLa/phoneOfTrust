class SessionsController < ApplicationController
  include VisitorAuth

  skip_before_action :authenticate_visitor!, only: [ :new, :create, :destroy ]

  def new
    if current_user_id
      redirect_to root_path
    else
      redirect_to initialize_visitor_path
    end
  end

  def create
    if !visitor_signed_in?
      sign_in_visitor
      redirect_to root_path
    end
  end

  #unused
  def destroy
    reset_visitor_session
    redirect_to root_path
  end

end
