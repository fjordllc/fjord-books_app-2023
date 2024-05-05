# frozen_string_literal: true

require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  setup do
    sign_in
  end

  test '他人のプロフィールは編集できない' do
    machida = users(:machida)
    visit user_path(machida)
    assert_no_link 'このユーザを編集'

    # 自分のプロフィールは編集可
    komagata = users(:komagata)
    visit user_path(komagata)
    assert_link 'このユーザを編集'
  end

  test 'ユーザのページネーション' do
    1.upto(30) do |n|
      User.create!(email: "user-#{n}@example.com", name: "ユーザ-#{n}", password: 'password')
    end

    visit users_path
    assert_text 'ユーザ-30'
    assert_text 'ユーザ-6'
    assert_no_text 'ユーザ-5'
    click_link '次'
    assert_no_text 'ユーザ-6'
    assert_text 'ユーザ-5'
    assert_text 'ユーザ-1'
  end
end
