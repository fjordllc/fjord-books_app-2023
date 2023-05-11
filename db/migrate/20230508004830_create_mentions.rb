class CreateMentions < ActiveRecord::Migration[7.0]
  def change
    create_table :mentions do |t|
      t.references :mentioning_report, foreign_key:{ to_table: :reports }, null: false
      t.references :mentioned_report, foreign_key:{ to_table: :reports }, null: false

      t.timestamps

      t.index [:mentioning_report_id, :mentioned_report_id], unique: true
    end
  end
end
