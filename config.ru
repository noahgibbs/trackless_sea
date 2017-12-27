require "dcjs/config_ru"

file = File.new File.join(__dir__, "log", "trackless.txt"), "a"
file.sync = true
use Rack::CommonLogger, file

use Rack::ShowExceptions  # Useful for debugging, turn off in production

EM.error_handler do |e|
  STDERR.puts "ERROR: #{e.message}\n#{e.backtrace.join "\n"}\n"
end

DCJS.rack_builder self
DCJS.root_dir __dir__
DCJS.coffeescript_dirs "trackless"
DCJS.static_dirs "tiles", "sprites", "vendor_js", "ui", "static"
DCJS.static_files "index.html"

require_relative "./game.rb"
run DCJS.handler
