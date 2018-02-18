class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table(:users, primary_key: :mobile, id: false) do |t|
      t.string :mobile
      t.integer :pin
      t.datetime :pin_due
      t.integer :bought_small, default: 0
      t.integer :bought_middle, default: 0
      t.integer :bought_big, default: 0
      t.integer :gained, default: 0
      t.integer :tickets_count, default: 0

      t.timestamps
    end
  end
end
