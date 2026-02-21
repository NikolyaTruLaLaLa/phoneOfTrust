module Admin
  class SessionsController < ApplicationController
    include AdminAuth

    layout "application"

    skip_before_action :authenticate_administrator!, only: [ :new, :create, :destroy ]

    def new
      redirect_to admin_root_path if administrator_signed_in?
    end

    def create
      administrator = Administrator.find_by(name: params[:name])

      if administrator&.authenticate(params[:password])
        sign_in_administrator(administrator)
        redirect_to admin_root_path, notice: "Вход выполнен успешно"
      else
        flash.now[:alert] = "Неверное имя или пароль"
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      sign_out_administrator
      redirect_to admin_login_path, notice: "Вы вышли из системы"
    end
  end
end
