class AddIndexesToStatuses < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute('SET lock_timeout TO \'60s\'')

      unless index_exists?(:statuses, :is_rss_content, unique: false, algorithm: :concurrently)
        add_index :statuses, :is_rss_content, algorithm: :concurrently
      end

      unless index_exists?(:statuses, :reply, unique: false, algorithm: :concurrently)
        add_index :statuses, :reply, algorithm: :concurrently
      end

      unless index_exists?(:statuses, :created_at, unique: false, algorithm: :concurrently)
        add_index :statuses, :created_at, algorithm: :concurrently
      end

      unless index_exists?(:statuses, [:is_rss_content, :reply, :created_at], unique: false, algorithm: :concurrently)
        add_index :statuses, [:is_rss_content, :reply, :created_at], algorithm: :concurrently
      end

      execute('RESET lock_timeout')
    end
  end

  def down
    safety_assured do
      execute('SET lock_timeout TO \'60s\'')

      if index_exists?(:statuses, :is_rss_content, unique: false, algorithm: :concurrently)
        remove_index :statuses, :is_rss_content
      end

      if index_exists?(:statuses, :reply, unique: false, algorithm: :concurrently)
        remove_index :statuses, :reply
      end

      if index_exists?(:statuses, :created_at, unique: false, algorithm: :concurrently)
        remove_index :statuses, :created_at
      end

      if index_exists?(:statuses, [:is_rss_content, :reply, :created_at], unique: false, algorithm: :concurrently)
        remove_index :statuses, column: [:is_rss_content, :reply, :created_at]
      end

      execute('RESET lock_timeout')
    end
  end
end
