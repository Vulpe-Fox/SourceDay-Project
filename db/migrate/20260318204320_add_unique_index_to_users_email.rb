class AddUniqueIndexToUsersEmail < ActiveRecord::Migration[8.1]
  def change
    if index_exists?(:users, :email)
      remove_index :users, :email
    end
    
    add_index :users, :email, unique: true
    change_column_null :users, :email, false
  end
end
