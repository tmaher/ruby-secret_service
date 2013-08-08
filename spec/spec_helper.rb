require 'rubygems'
require 'bundler/setup'
require 'securerandom'

$: << File.dirname(__FILE__) + '/../lib'

require 'secret_service'

RSpec.configure do |config|
  config.color_enabled = true
  config.order = 'random'
  config.seed = SecureRandom.random_number(2 ** 24)
  
  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  #config.formatter = :documentation # :progress, :html, :textmate
end
