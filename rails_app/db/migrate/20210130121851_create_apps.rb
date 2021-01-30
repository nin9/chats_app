class CreateApps < ActiveRecord::Migration[5.2]
  def change
    create_table :apps do |t|
      t.string :name
      t.string :token
      t.index :token, unique: true
      t.integer :chats_count, default: 0
      t.timestamps
    end
  end
end
