class AddManagerToColaborator < ActiveRecord::Migration[6.0]
  def change
    add_reference :collaborators, :manager, type: :uuid, null: true, foreign_key: false
  end
end
