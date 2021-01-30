class CreateChats < ActiveRecord::Migration[5.2]
  def change
    create_table :chats do |t|
      t.references :app, index: true, foreign_key: true
      t.integer :number, null: false
      t.integer :messages_count, default: 0
      t.timestamps
    end
    add_index :chats, %i[app_id number], unique: true
  end
end
