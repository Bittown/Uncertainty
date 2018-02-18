class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.integer :created_by, null: false
      t.datetime :exposed_at, default: nil
      t.datetime :should_expose_at, null: false
      t.integer :tickets_count, default: 0
      t.integer :result, default: 0
      t.integer :sold_small, default: 0
      t.integer :sold_middle, default: 0
      t.integer :sold_big, default: 0
      t.integer :paid, default: 0
      t.integer :should_pay, default: 0
      t.string :bg_style, null: false
      t.string :ground_style, null: false
      t.string :first_character_color, default: 'blue'
      t.string :second_character_color, default: 'pink'

      t.timestamps
    end

    add_index :games, :created_by
    add_foreign_key :games, :admins, column: :created_by, primary_key: :id
  end
end
