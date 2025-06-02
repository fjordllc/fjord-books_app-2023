# frozen_string_literal: true

require 'application_system_test_case'

class DeviseTest < ApplicationSystemTestCase
  test 'sign up / sign in / sign out / edit profile / edit password' do
    # 既存のデータは全件削除
    User.destroy_all

    # アカウント登録
    visit root_path
    assert_css 'h2', text: 'ログイン'
    click_link 'アカウント登録'

    # バリデーションエラーを発生させる
    click_button 'アカウント登録'
    assert_text '2 件のエラーが発生したため ユーザ は保存されませんでした。'

    fill_in 'Eメール', with: 'alice@example.com'
    fill_in '氏名', with: 'アリス'
    fill_in '郵便番号', with: '156-0043'
    fill_in '住所', with: '東京都世田谷区松原2-34-11 ベルヴィカワダ 201'
    fill_in '自己紹介文', with: 'よろしくお願いします。'
    attach_file 'ユーザ画像', Rails.root.join('test/fixtures/files/piyord.png')
    fill_in 'パスワード', with: 'password'
    fill_in 'パスワード（確認用）', with: 'password'
    click_button 'アカウント登録'
    assert_text 'アカウント登録が完了しました。'
    assert_text 'アリス としてログイン中'

    # ログアウトとログイン
    click_button 'ログアウト'
    assert_text 'ログアウトしました。'
    assert_css 'h2', text: 'ログイン'

    # バリデーションエラーを発生させる
    fill_in 'Eメール', with: 'alice@example.com'
    fill_in 'パスワード', with: 'hogehoge'
    click_button 'ログイン'
    assert_text 'Eメールまたはパスワードが違います。'

    fill_in 'Eメール', with: 'alice@example.com'
    fill_in 'パスワード', with: 'password'
    click_button 'ログイン'
    assert_text 'ログインしました。'

    # 登録情報の確認
    click_link 'ユーザ'
    assert_css 'h1', text: 'ユーザの一覧'
    within '#users' do
      assert_text 'alice@example.com'
      assert_text 'アリス'
      assert_text '156-0043'
      assert_text '東京都世田谷区松原2-34-11 ベルヴィカワダ 201'
      click_link 'このユーザを表示'
    end
    assert_css 'h1', text: 'ユーザの詳細'
    assert_text 'alice@example.com'
    assert_text 'アリス'
    assert_text '156-0043'
    assert_text '東京都世田谷区松原2-34-11 ベルヴィカワダ 201'
    assert_text 'よろしくお願いします。'
    assert find('img')['src'].end_with?('piyord.png')

    # アカウント編集
    click_link 'アカウント編集'

    # バリデーションエラーを発生させる
    fill_in 'Eメール', with: ''
    click_button '更新'
    assert_text 'エラーが発生したため ユーザ は保存されませんでした。'

    fill_in 'Eメール', with: 'alice-2@example.com'
    fill_in '氏名', with: 'ありす'
    fill_in '郵便番号', with: '156-9999'
    fill_in '住所', with: '東京都世田谷区松原2-34-11 ベルヴィカワダ 999'
    fill_in '自己紹介文', with: 'よろしくお願いします！'
    attach_file 'ユーザ画像', Rails.root.join('test/fixtures/files/komagata.jpg')
    fill_in '現在のパスワード', with: 'password'
    click_button '更新'
    assert_text 'アカウント情報を変更しました。'

    # 編集情報の確認
    user = User.find_by(email: 'alice-2@example.com')
    visit user_path(user)
    assert_text 'alice-2@example.com'
    assert_text 'ありす'
    assert_text '156-9999'
    assert_text '東京都世田谷区松原2-34-11 ベルヴィカワダ 999'
    assert_text 'よろしくお願いします！'
    assert find('img')['src'].end_with?('komagata.jpg')

    # パスワードの変更と再ログイン
    click_link 'アカウント編集'
    fill_in 'パスワード', with: 'password!!'
    fill_in 'パスワード（確認用）', with: 'password!!'
    fill_in '現在のパスワード', with: 'password'
    click_button '更新'
    assert_text 'アカウント情報を変更しました。'
    assert_current_path user_path(user)

    click_button 'ログアウト'
    assert_text 'ログアウトしました。'
    assert_css 'h2', text: 'ログイン'
    fill_in 'Eメール', with: 'alice-2@example.com'
    fill_in 'パスワード', with: 'password!!'
    click_button 'ログイン'
    assert_text 'ログインしました。'
  end

  test 'reset password' do
    visit root_path
    click_link 'パスワードを忘れましたか？'

    # バリデーションエラーを発生させる
    click_button 'パスワードの再設定方法を送信する'
    assert_text 'エラーが発生したため ユーザ は保存されませんでした。'

    fill_in 'Eメール', with: 'komagata@example.com'
    click_button 'パスワードの再設定方法を送信する'
    assert_text 'パスワードの再設定について数分以内にメールでご連絡いたします。'

    mail = ActionMailer::Base.deliveries.last
    m = mail.body.encoded.match(%r{http://example.com/(?<path>[-\w_?/=]+)})
    visit m[:path]
    assert_css 'h2', text: 'パスワードを変更'

    # バリデーションエラーを発生させる
    click_button 'パスワードを変更する'
    assert_text 'エラーが発生したため ユーザ は保存されませんでした。'

    fill_in '新しいパスワード', with: 'pass1234'
    fill_in '確認用新しいパスワード', with: 'pass1234'
    click_button 'パスワードを変更する'
    assert_text 'パスワードが正しく変更されました。'
  end

  test 'delete account' do
    visit root_path

    fill_in 'Eメール', with: 'komagata@example.com'
    fill_in 'パスワード', with: 'password'
    click_button 'ログイン'
    assert_text 'ログインしました。'

    click_link 'アカウント編集'
    accept_alert do
      click_button 'アカウント削除'
    end
    assert_text 'アカウントを削除しました。またのご利用をお待ちしております。'
    assert_current_path new_user_session_path
  end
end
