# Required from config.ru

# TODO: Set the HTML canvas from these? Or vice-versa?
CANVAS_WIDTH = 640
CANVAS_HEIGHT = 480

class GoodShip
  def initialize
    terrain = Demiurge::Createjs.sprites_from_tmx File.join(__dir__, "tmx", "terrain-test.tmx")
    @terrain_spritesheet = terrain[:spritesheet]
    @terrain_spritestack = terrain[:spritestack]
    @terrain_spritestack["name"] = "terrain-test"

    terrain = Demiurge::Createjs.sprites_from_manasource_tmx File.join(__dir__, "tmx", "evol-boat.tmx")
    @boat_spritesheet = terrain[:spritesheet]
    @boat_spritestack = terrain[:spritestack]
    @boat_collision = terrain[:collision]
    @boat_spritestack["name"] = "evol-boat"

    @zone = Demiurge::Createjs::Zone.new spritestack: @boat_spritestack, spritesheet: @boat_spritesheet
  end

  def on_open(options)
    socket = options[:transport]
    player = Demiurge::Createjs::Player.new transport: Demiurge::Createjs::Transport.new(socket), name: "player", width: CANVAS_WIDTH, height: CANVAS_HEIGHT
    player.zone = @zone

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
    #EM.add_timer(3.0) do
    #  player.send_pan_to_pixel_offset(500, 500, "duration" => 10.0)
    #end
    #EM.add_timer(13.0) do
    #  player.send_animation "stand_right"
    #end
  end
end

Demiurge::Createjs.record_traffic
Demiurge::Createjs.run GoodShip.new
