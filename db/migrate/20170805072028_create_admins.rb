class CreateAdmins < ActiveRecord::Migration[5.1]
  def change
    create_table :admins do |t|
      t.string :mobile, null: false
      t.string :name, null: false
      t.string :password_digest, null: false
      t.integer :level, default: 0
      t.integer :pin
      t.datetime :pin_due

      t.timestamps
    end

    add_index :admins, :mobile, unique: true
  end
end
