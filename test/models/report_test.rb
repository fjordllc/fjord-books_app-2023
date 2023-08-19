# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  test 'editable?' do
    report = reports(:komagata)
    komagata = users(:komagata)
    machida = users(:machida)

    assert report.editable?(komagata)
    assert_not report.editable?(machida)
  end

  test 'created_on' do
    report = reports(:komagata)
    assert_equal Date.current, report.created_on
  end

  test 'mention' do
    komagata_report = reports(:komagata)
    matz_report = reports(:matz)

    machida = users(:machida)
    # 新規作成時
    # - 存在しないレポートのURLは無視する
    machida_report = machida.reports.create!(
      title: '初日報です',
      content: <<~CONTENT
        駒形さんの日報を読みました。
        http://localhost:3000/reports/#{komagata_report.id}

        Matzさんの日報を読みました。
        http://localhost:3000/reports/#{matz_report.id}

        存在しないレポートを読みました
        http://localhost:3000/reports/0
      CONTENT
    )
    [komagata_report, matz_report, machida_report].each(&:reload)
    assert_equal [machida_report], komagata_report.mentioned_reports
    assert_equal [machida_report], matz_report.mentioned_reports
    assert_equal [komagata_report, matz_report].sort, machida_report.mentioning_reports.sort

    # 更新時
    # - 削除されたURLは言及がなくなる
    # - 重複したURLは1つにまとめる
    # - 自分自身のURLは無視する
    machida_report.update!(title: '初日報です', content: <<~CONTENT)
      Matzさんの日報を読みました。
      http://localhost:3000/reports/#{matz_report.id}
      http://localhost:3000/reports/#{matz_report.id}

      これは私の日報です。
      http://localhost:3000/reports/#{machida_report.id}
    CONTENT
    [komagata_report, matz_report, machida_report].each(&:reload)
    assert_equal [], komagata_report.mentioned_reports
    assert_equal [machida_report], matz_report.mentioned_reports
    assert_equal [matz_report], machida_report.mentioning_reports

    # 削除時
    # - 言及もなくなる
    machida_report.destroy
    assert_equal [], matz_report.reload.mentioned_reports
  end
end
