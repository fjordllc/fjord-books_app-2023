# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'name_or_email' do
    user = users(:komagata)
    assert_equal '駒形 真幸', user.name_or_email

    user.name = ''
    assert_equal 'komagata@example.com', user.name_or_email
  end
end
