Bundler.require :default

require "faye/websocket"
require "rack/coffee"

# Can also be Puma
Faye::WebSocket.load_adapter('thin')

#require "demiurge-createjs"

require_relative "./game.rb"

file = File.new File.join(__dir__, "log", "trackless.txt"), "a+"
file.sync = true
use Rack::CommonLogger, file

use Rack::ShowExceptions

# Serve .js files from .coffee files dynamically
# TODO: figure out how to serve CoffeeScript stuff from the right dynamic root
coffee_root = File.join(__dir__, "..", "demiurge-createjs")
use Rack::Coffee, :root => coffee_root, :urls => "/scripts"

use Rack::Static, :urls => ["/tiles", "/sprites", "/vendor_js"]

def combined_handler
  Proc.new do |env|
    if Faye::WebSocket.websocket? env
      Demiurge::Createjs.websocket_handler env
    else
      # Currently this always serves index.html for any non-websocket request
      [200, {'Content-Type' => 'text/html'}, [File.read("index.html")]]
    end
  end
end

EM.error_handler do |e|
  STDERR.puts "ERROR: #{e.message}\n#{e.backtrace.join "\n"}\n"
end

run combined_handler
