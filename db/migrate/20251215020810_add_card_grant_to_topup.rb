class AddCardGrantToTopup < ActiveRecord::Migration[8.1]
  def change
    add_column :topups, :cdg_id, :string
  end
end
