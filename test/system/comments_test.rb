# frozen_string_literal: true

require 'application_system_test_case'

class CommentsTest < ApplicationSystemTestCase
  setup do
    sign_in
  end

  test '本のコメントを削除できるのはコメント投稿者のみ' do
    book = Book.create!(title: 'チェリー本')
    machida = users(:machida)
    book.comments.create!(user: machida, content: 'ためになりました。')

    visit book_path(book)
    within '.comments-container' do
      assert_text 'ためになりました。'
      assert_no_button '削除'
    end

    fill_in 'comment[content]', with: 'とても役に立ちました。'
    click_button 'コメントする'
    assert_text 'コメントが作成されました。'
    within '.comments-container' do
      assert_text 'ためになりました。'
      assert_text 'とても役に立ちました。'
      assert_button '削除', count: 1

      accept_alert do
        click_button '削除'
      end
    end

    assert_text 'コメントが削除されました。'
    assert_current_path book_path(book)
    within '.comments-container' do
      assert_text 'ためになりました。'
      assert_no_text 'とても役に立ちました。'
      assert_no_button '削除'
    end
  end

  test '日報のコメントを削除できるのはコメント投稿者のみ' do
    report = reports(:komagata)
    machida = users(:machida)
    report.comments.create!(user: machida, content: 'ためになりました。')

    visit report_path(report)
    within '.comments-container' do
      assert_text 'ためになりました。'
      assert_no_button '削除'
    end

    fill_in 'comment[content]', with: 'とても役に立ちました。'
    click_button 'コメントする'
    assert_text 'コメントが作成されました。'
    within '.comments-container' do
      assert_text 'ためになりました。'
      assert_text 'とても役に立ちました。'
      assert_button '削除', count: 1

      accept_alert do
        click_button '削除'
      end
    end

    assert_text 'コメントが削除されました。'
    assert_current_path report_path(report)
    within '.comments-container' do
      assert_text 'ためになりました。'
      assert_no_text 'とても役に立ちました。'
      assert_no_button '削除'
    end
  end
end
