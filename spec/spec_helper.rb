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

def hide_dbus_configs
  state = {:addr => ENV["DBUS_SESSION_BUS_ADDRESS"],
    :display => ENV["DISPLAY"],
    :dir => File.join(ENV["HOME"], ".dbus-#{SecureRandom.hex(4)}")
  }
  ENV.delete "DBUS_SESSION_BUS_ADDRESS"
  ENV.delete "DISPLAY"
  begin
    File.rename File.join(ENV["HOME"], ".dbus"), state[:dir]
  rescue; end
  state
end

def restore_dbus_configs state
  ENV["DBUS_SESSION_BUS_ADDRESS"] = state[:addr]
  ENV["DISPLAY"] = state[:display]
  begin
    File.rename state[:dir], File.join(ENV["HOME"], ".dbus")
  rescue; end
end
