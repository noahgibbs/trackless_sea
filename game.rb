# This file is required from config.ru

require "demiurge/dsl"
require "demiurge/tmx"

require "demiurge/createjs/engine_sync"

# TODO: Set the HTML canvas from these? Or vice-versa?
CANVAS_WIDTH = 640
CANVAS_HEIGHT = 480

class GoodShip
  def initialize
    @engine = Demiurge.engine_from_dsl_files *Dir["world/*.rb"]
    @engine_sync = Demiurge::Createjs::EngineSync.new(@engine)
    @player_by_transport = {}
  end

  def on_open(transport:, event:)
    unless @engine_started
      # TODO: Figure out a way to do this initially instead of waiting for a first socket to be opened.
      EM.add_periodic_timer(1) do
        # Step game content forward by one tick - currently ignoring the player, which isn't in Demiurge
        intentions = @engine.next_step_intentions
        @engine.apply_intentions(intentions)
      end
      @engine_started = true
    end

    @player_by_transport[transport] = Demiurge::Createjs::Player.new transport: Demiurge::Createjs::Transport.new(transport), name: "player", engine_sync: @engine_sync, location_name: "start location", width: CANVAS_WIDTH, height: CANVAS_HEIGHT
  end

  def on_error(transport:, event:)
    puts "Protocol error for player #{@player_by_transport[transport]}: #{event.inspect}"
  end

  def on_close(transport:, event:)
    p [:close, event.code, event.reason].inspect
  end
end

Demiurge::Createjs.record_traffic
Demiurge::Createjs.run GoodShip.new
