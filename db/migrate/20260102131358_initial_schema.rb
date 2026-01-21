class InitialSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :chats do |t|
      t.string :status
      t.string :visitors_token
      t.datetime :ended_at
      t.timestamps
    end

    add_index :chats, :visitors_token, unique: true

    create_table :messages do |t|
      t.references :chat, null: false, foreign_key: true
      t.string :sender
      t.text :content
      t.timestamps
    end
  end
end
