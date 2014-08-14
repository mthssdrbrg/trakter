class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.string :token
      t.datetime :created_at
    end
    add_index :exports, :token
    add_index :exports, :created_at
  end
end
