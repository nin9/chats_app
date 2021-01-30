class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.text :body, null: false
      t.integer :number, null: false
      t.references :chat, index: true, foreign_key: true

      t.timestamps
    end
    add_index :messages, %i[chat_id number], unique: true
  end
end
