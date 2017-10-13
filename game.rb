# This file is required from config.ru

require "demiurge/dsl"
require "demiurge/tmx"

# TODO: Set the HTML canvas from these? Or vice-versa?
CANVAS_WIDTH = 640
CANVAS_HEIGHT = 480

class GoodShip
  def initialize
    @engine = Demiurge.engine_from_dsl_files *Dir["world/*.rb"]

    @start_location = @engine.item_by_name("start location")
    start_obj = @start_location.tiles[:objects].detect { |obj| obj[:name] == "start location" }
    if start_obj
      @start_x = start_obj[:x] / 32
      @start_y = start_obj[:y] / 32
    else
      STDERR.puts "WARNING: cannot locate object 'start location' in starting TMX area!"
    end

    @start_zone = Demiurge::Createjs::Zone.new spritestack: @start_location.tiles[:spritestack], spritesheet: @start_location.tiles[:spritesheet]
  end

  def on_open(options)
    socket = options[:transport]
    player = Demiurge::Createjs::Player.new transport: Demiurge::Createjs::Transport.new(socket), name: "player", width: CANVAS_WIDTH, height: CANVAS_HEIGHT
    player.zone = @start_zone

    #@start_x ||= @engine.state_for_item("start location")["start_x"]
    #@start_y ||= @engine.state_for_item("start location")["start_y"]

    player.display
    player.teleport_to_tile @start_x, @start_y
    player.walk_to_tile 18, 16, "speed" => 5.0

    EM.add_timer(5) do
      player.walk_to_tile 12, 20, "speed" => 5.0
      EM.add_timer(5) do
        player.walk_to_tile 16, 16, "speed" => 5.0
        EM.add_timer(5) do
          player.walk_to_tile 30, 30, "speed" => 5.0
        end
      end
    end
  end
end

Demiurge::Createjs.record_traffic
Demiurge::Createjs.run GoodShip.new
