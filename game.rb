# This file is required from config.ru

require "demiurge/dsl"
require "demiurge/tmx"

require "demiurge/createjs/engine_sync"
require "demiurge/createjs/engine_accounts"
require "demiurge/createjs/login_unique"

# TODO: Set the HTML canvas from these? Or vice-versa?
CANVAS_WIDTH = 640
CANVAS_HEIGHT = 480

class GoodShip
  # Store player accounts inside the Demiurge engine state
  include Demiurge::Createjs::EngineAccounts;
  include Demiurge::Createjs::LoginUnique;

  def initialize
    @engine = Demiurge.engine_from_dsl_files *Dir["world/*.rb"]
    @engine_sync = Demiurge::Createjs::EngineSync.new(@engine)
    set_accounts_engine_sync(@engine_sync)
  end

  def on_create_player(websocket, username)
    # Set the start location and the canvas size...
    player = Demiurge::Createjs::Player.new websocket: websocket, name: username, engine_sync: @engine_sync, location_name: "start location", width: CANVAS_WIDTH, height: CANVAS_HEIGHT
    player.message "displayInit", { "width" => CANVAS_WIDTH, "height" => CANVAS_HEIGHT }
    player
  end

  def on_open(transport:, event:)
    unless @engine_started
      # TODO: Figure out a way to do this initially instead of waiting for a first socket to be opened.
      EM.add_periodic_timer(1) do
        # Step game content forward by one tick
        intentions = @engine.next_step_intentions
        @engine.apply_intentions(intentions, :nofreeze => true)  # We use account data in the engine state, so we can't freeze between steps.
      end
      @engine_started = true
    end

    # Now, wait for login.
  end

  def on_error(transport:, event:)
    puts "Protocol error for player #{@player_by_transport[transport]}: #{event.inspect}"
  end
end

Demiurge::Createjs.record_traffic
Demiurge::Createjs.run GoodShip.new
