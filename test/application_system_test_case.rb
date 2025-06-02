# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |options|
    options.add_argument('--disable-gpu')
    options.add_preference('profile.password_manager_leak_detection', false)
  end
end
