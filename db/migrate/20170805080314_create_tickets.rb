class CreateTickets < ActiveRecord::Migration[5.1]
  def change
    create_table :tickets do |t|
      t.integer :game_id, null: false
      t.integer :station_id, null: false
      t.string :user_mobile, null: false
      t.integer :amount, null: false
      t.integer :forecast, null: false
      t.boolean :paid, default: false

      t.timestamps
    end

    add_index :tickets, :game_id
    add_index :tickets, :station_id
    add_index :tickets, :user_mobile
    add_foreign_key :tickets, :games, column: :game_id, primary_key: :id
    add_foreign_key :tickets, :stations, column: :station_id, primary_key: :id
    add_foreign_key :tickets, :users, column: :user_mobile, primary_key: :mobile
  end
end
