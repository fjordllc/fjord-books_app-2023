class RenameReportMentionsColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column :report_mentions, :mention_to_id, :mentioning_id
    rename_column :report_mentions, :mentioned_by_id, :mentioned_id
  end
end
