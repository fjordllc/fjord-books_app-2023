# frozen_string_literal: true

require 'test_helper'

class ReportsAuthorizationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @report = reports(:machida)

    komagata = users(:komagata)
    sign_in(komagata)
  end

  test '他人の日報は編集できない' do
    assert_raise(ActiveRecord::RecordNotFound) { get edit_report_path(@report) }
  end

  test '他人の日報は更新できない' do
    assert_raise(ActiveRecord::RecordNotFound) { put report_path(@report) }
  end

  test '他人の日報は削除できない' do
    assert_raise(ActiveRecord::RecordNotFound) { delete report_path(@report) }
  end
end
