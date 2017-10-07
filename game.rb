# This file is required from config.ru

require "demiurge/dsl"

# TODO: Set the HTML canvas from these? Or vice-versa?
CANVAS_WIDTH = 640
CANVAS_HEIGHT = 480

class GoodShip
  def initialize
    @engine = Demiurge.engine_from_dsl_files *Dir["world/*.rb"]

    terrain = @engine.item_by_name("start location")

    boat_collision = terrain[:collision]
    boat_spritestack["name"] = "evol-boat"  # Debug data? Why is this here?

    @start_zone = Demiurge::Createjs::Zone.new spritestack: terrain[:spritestack], spritesheet: terrain[:spritesheet]
  end

  def on_open(options)
    socket = options[:transport]
    player = Demiurge::Createjs::Player.new transport: Demiurge::Createjs::Transport.new(socket), name: "player", width: CANVAS_WIDTH, height: CANVAS_HEIGHT
    player.zone = @start_zone

    player.display
    player.teleport_to_tile 3, 3
    player.walk_to_tile 16, 8, "speed" => 5.0
    EM.add_timer(5) do
      player.walk_to_tile 8, 16, "speed" => 5.0
      EM.add_timer(5) do
        player.walk_to_tile 16, 16, "speed" => 5.0
        EM.add_timer(5) do
          player.walk_to_tile 4, 4, "speed" => 5.0
        end
      end
    end
  end
end

Demiurge::Createjs.record_traffic
Demiurge::Createjs.run GoodShip.new
