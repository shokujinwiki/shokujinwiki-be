class ChangeNameNullOnUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :name, false
  end
end
