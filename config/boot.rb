ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

# https://zenn.dev/ayu0819/articles/3d361c5a14c2df
require "logger"

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
