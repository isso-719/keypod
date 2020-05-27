class CreateWorkspaces < ActiveRecord::Migration[5.2]
  def change
    create_table :workspaces do |t|
      t.references :user
      t.string :name
      t.string :url
    end
  end
end
