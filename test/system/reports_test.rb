# frozen_string_literal: true

require 'application_system_test_case'

class ReportsTest < ApplicationSystemTestCase
  setup do
    sign_in
  end

  test '日報のCRUD' do
    # 既存のデータは全件削除
    Report.destroy_all

    # 日報の登録
    click_link '日報'
    assert_css 'h1', text: '日報の一覧'
    click_link '日報の新規作成'
    assert_css 'h1', text: '日報の新規作成'

    # バリデーションエラーを発生させる
    click_button '登録する'
    assert_text '2件のエラーがあるため、この日報は保存できませんでした'

    fill_in 'タイトル', with: 'はじめての日報'
    fill_in '内容', with: 'はじめまして。よろしくお願いします。'
    click_button '登録する'

    assert_text '日報が作成されました。'
    assert_text 'はじめての日報'
    assert_text 'はじめまして。よろしくお願いします。'

    # 日報の編集
    click_link 'この日報を編集'
    assert_css 'h1', text: '日報の編集'

    # バリデーションエラーを発生させる
    fill_in 'タイトル', with: ''
    click_button '更新する'
    assert_text '1件のエラーがあるため、この日報は保存できませんでした'

    fill_in 'タイトル', with: 'My first report'
    fill_in '内容', with: 'Hello, everyone!'
    click_button '更新する'
    assert_text '日報が更新されました。'
    assert_text 'My first report'
    assert_text 'Hello, everyone!'

    # コメント登録
    fill_in 'comment[content]', with: 'コメントお待ちしています！'
    click_button 'コメントする'
    assert_text 'コメントが作成されました。'
    assert_text 'コメントお待ちしています！'

    # 日報の一覧と日報の削除
    click_link '日報の一覧に戻る'
    assert_css 'h1', text: '日報の一覧'
    within '#reports' do
      assert_text 'My first report'
      click_link 'この日報を表示'
    end
    assert_css 'h1', text: '日報の詳細'
    click_button 'この日報を削除'
    assert_text '日報が削除されました。'
    within '#reports' do
      assert_no_text 'My first report'
    end
  end

  test '日報のページネーション' do
    user = users(:komagata)
    1.upto(30) do |n|
      user.reports.create!(title: "日報-#{n}", content: '日報です。')
    end

    visit reports_path
    assert_text '日報-30'
    assert_text '日報-6'
    assert_no_text '日報-5'
    click_link '次'
    assert_no_text '日報-6'
    assert_text '日報-5'
    assert_text '日報-1'
  end

  test '他人の日報は編集できない' do
    report = reports(:machida)
    visit report_path(report)
    assert_no_link 'この日報を編集'
    assert_no_button 'この日報を削除'
  end

  test '言及機能' do
    matz_report = reports(:matz)
    visit report_path(matz_report)
    within '.mentions-container' do
      assert_text 'この日報に言及している日報はまだありません'
    end

    # 新規作成
    visit new_report_path
    fill_in 'タイトル', with: 'Matzさんに感謝'
    fill_in '内容', with: <<~CONTENT
      この日報は最高でした。
      http://localhost:3000/reports/#{matz_report.id}
    CONTENT
    click_button '登録する'
    assert_text '日報が作成されました。'

    my_report = Report.find_by(title: 'Matzさんに感謝')

    visit report_path(matz_report)
    within '.mentions-container' do
      assert_no_text 'この日報に言及している日報はまだありません'
      assert_link 'Matzさんに感謝'
    end

    machida_report = reports(:machida)
    visit report_path(machida_report)
    within '.mentions-container' do
      assert_text 'この日報に言及している日報はまだありません'
    end

    # 更新
    visit edit_report_path(my_report)
    fill_in 'タイトル', with: 'machidaさんに感謝'
    fill_in '内容', with: <<~CONTENT
      この日報は最高でした。
      http://localhost:3000/reports/#{machida_report.id}
    CONTENT
    click_button '更新する'
    assert_text '日報が更新されました。'

    visit report_path(matz_report)
    within '.mentions-container' do
      assert_text 'この日報に言及している日報はまだありません'
    end

    visit report_path(machida_report)
    within '.mentions-container' do
      assert_no_text 'この日報に言及している日報はまだありません'
      assert_link 'machidaさんに感謝'
    end
  end
end
