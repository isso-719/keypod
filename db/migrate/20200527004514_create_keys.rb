class CreateKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :keys do |t|
      t.references :workspace
      t.string :key
      t.string :path
      t.string :description
      t.string :data_type
    end
  end
end
