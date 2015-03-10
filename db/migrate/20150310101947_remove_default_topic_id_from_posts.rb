class RemoveDefaultTopicIdFromPosts < ActiveRecord::Migration
  def up
    change_column_default :posts, :topic_id, nil
  end

  def down
    change_column_default :posts, :topic_id, 0
  end
end
