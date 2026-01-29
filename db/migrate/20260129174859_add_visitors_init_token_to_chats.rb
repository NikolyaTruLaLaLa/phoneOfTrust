class AddVisitorsInitTokenToChats < ActiveRecord::Migration[8.1]
  def change
    add_column :chats, :visitors_init_token, :string
  end
end
