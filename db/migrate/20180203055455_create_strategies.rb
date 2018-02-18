class CreateStrategies < ActiveRecord::Migration[5.1]
  def change
    create_table :strategies, primary_key: :key, id: false do |t|
      t.string :key, null: false
      t.string :value
      t.string :describe, null: false
      t.boolean :root, default: false

      t.timestamps
    end
  end
end
