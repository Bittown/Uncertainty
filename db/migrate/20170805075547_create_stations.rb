class CreateStations < ActiveRecord::Migration[5.1]
  def change
    create_table :stations do |t|
      t.string :mobile, null: false
      t.string :name, null: false
      t.string :password_digest, null: false
      t.boolean :active, default: false
      t.integer :pin
      t.datetime :pin_due
      t.integer :sold_small, default: 0
      t.integer :sold_middle, default: 0
      t.integer :sold_big, default: 0
      t.integer :paid, default: 0
      t.integer :should_pay, default: 0
      t.integer :tickets_count, default: 0

      t.timestamps
    end

    add_index :stations, :mobile, unique: true
  end
end
