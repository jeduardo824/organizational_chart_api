class CreateCollaborators < ActiveRecord::Migration[6.0]
  def change
    create_table :collaborators, id: :uuid do |t|
      t.string :name
      t.string :email
      t.references :company, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
