# frozen_string_literal: true

require 'application_system_test_case'

class BooksTest < ApplicationSystemTestCase
  setup do
    sign_in
  end

  test '本のCRUD' do
    # 本の登録
    click_link '本'
    assert_css 'h1', text: '本の一覧'
    click_link '本の新規作成'
    assert_css 'h1', text: '本の新規作成'
    fill_in 'タイトル', with: 'プロを目指す人のためのRuby入門'
    fill_in 'メモ', with: 'Rubyの文法をサンプルコードで学び、例題でプログラミングの流れを体験できる解説書です。'
    fill_in '著者', with: '伊藤 淳一'
    attach_file '画像', Rails.root.join('test/fixtures/files/cherry.jpg')
    click_button '登録する'

    assert_text '本が作成されました。'
    assert_text 'プロを目指す人のためのRuby入門'
    assert_text 'Rubyの文法をサンプルコードで学び、例題でプログラミングの流れを体験できる解説書です。'
    assert_text '伊藤 淳一'
    assert find('img')['src'].end_with?('cherry.jpg')

    # 本の編集
    click_link 'この本を編集'
    assert_css 'h1', text: '本の編集'
    fill_in 'タイトル', with: 'チェリー本'
    fill_in 'メモ', with: 'Railsをやる前に、Rubyを知ろう'
    fill_in '著者', with: 'jnchito'
    click_button '更新する'
    assert_text '本が更新されました。'
    assert_text 'チェリー本'
    assert_text 'Railsをやる前に、Rubyを知ろう'
    assert_text 'jnchito'

    # コメント登録
    fill_in 'comment[content]', with: 'とても役に立ちました。'
    click_button 'コメントする'
    assert_text 'コメントが作成されました。'
    assert_text 'とても役に立ちました。'

    # 本の一覧と本の削除
    click_link '本の一覧に戻る'
    assert_css 'h1', text: '本の一覧'
    within '#books' do
      assert_text 'チェリー本'
      assert_text 'Railsをやる前に、Rubyを知ろう'
      assert_text 'jnchito'
      click_link 'この本を表示'
    end
    assert_css 'h1', text: '本の詳細'
    click_button 'この本を削除'
    assert_text '本が削除されました。'
    within '#books' do
      assert_no_text 'チェリー本'
    end
  end

  test '本のページネーション' do
    1.upto(30) do |n|
      Book.create!(title: "本-#{n}")
    end

    visit books_path
    assert_text '本-30'
    assert_text '本-6'
    assert_no_text '本-5'
    click_link '次'
    assert_no_text '本-6'
    assert_text '本-5'
    assert_text '本-1'
  end
end
