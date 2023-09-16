class CreateReportMentions < ActiveRecord::Migration[7.0]
  def change
    create_table :report_mentions do |t|
      t.references :mention_to, null: false, foreign_key: { to_table: 'reports' }, index: false
      t.references :mentioned_by, null: false, foreign_key: { to_table: 'reports' }

      t.timestamps
    end
    add_index :report_mentions, %i[mention_to_id mentioned_by_id], unique: true
  end
end
