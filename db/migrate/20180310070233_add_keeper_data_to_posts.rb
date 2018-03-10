class AddKeeperDataToPosts < ActiveRecord::Migration[5.1]
  def change
    Post.without_timeout do
      add_column :posts, :keeper_data, :text
    end
  end
end
