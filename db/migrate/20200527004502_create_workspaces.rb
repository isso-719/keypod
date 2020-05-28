class CreateWorkspaces < ActiveRecord::Migration[5.2]
  def change
    create_table :workspaces do |t|
      t.references :user
      t.string :name
      t.string :url
      t.string :description
      t.timestamps null: false
    end
  end
end
