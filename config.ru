Bundler.require :default

# Can also be Puma
Faye::WebSocket.load_adapter('thin')

#require "demiurge-createjs"

require_relative "./game.rb"

file = File.new File.join(__dir__, "log", "trackless.txt"), "a+"
file.sync = true
use Rack::CommonLogger, file

use Rack::ShowExceptions

# Serve .js files from .coffee files dynamically
use Rack::Coffee, :urls => ""  # TODO: how will these be served when it's a gem?
use Rack::Static, :urls => ["/tiles", "/sprites", "/scripts/vendor"]

def combined_handler
  Proc.new do |env|
    if Faye::WebSocket.websocket? env
      PDM.websocket_handler env
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
