class HomeController < ApplicationController
include VisitorCreateAuthToken

def index
  if current_user_id.present?
    @chat = Chat.find_by(visitors_init_token: current_user_id, status: [ "waiting", "active" ])
  end
end
end
