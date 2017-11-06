# This file is required from config.ru

require "demiurge/dsl"
require "demiurge/tmx"

require "demiurge/createjs/engine_sync"
require "demiurge/createjs/json_accounts"
require "demiurge/createjs/login_unique"

# TODO: Set the HTML canvas from these? Or vice-versa?
CANVAS_WIDTH = 640
CANVAS_HEIGHT = 480

class GoodShip
  # Store player accounts in a JSON file
  include Demiurge::Createjs::JsonAccounts;
  # Only one login per player at a time
  include Demiurge::Createjs::LoginUnique;

  def initialize
    @engine = Demiurge.engine_from_dsl_files *Dir["world/*.rb"]
    @engine_sync = Demiurge::Createjs::EngineSync.new(@engine)
    @template = @engine.item_by_name("player template")
    @start_location = @engine.item_by_name("start location")
    start_obj = @start_location.tmx_object_by_name("start location")
    tilewidth = @start_location.tiles[:spritesheet][:tilewidth]
    tileheight = @start_location.tiles[:spritesheet][:tileheight]
    @start_position = "start location##{start_obj[:x] / tilewidth},#{start_obj[:y] / tileheight}"
    raise("Can't find player template object!") unless @template
    set_accounts_json_filename("accounts.json")
  end

  def on_create_player(websocket, username)
    body = @engine.instantiate_new_item("#{username}_player_agent", @template, "position" => @start_position)
    player = Demiurge::Createjs::Player.new websocket: websocket, name: username, demi_agent: body, engine_sync: @engine_sync, width: CANVAS_WIDTH, height: CANVAS_HEIGHT
    player.message "displayInit", { "width" => CANVAS_WIDTH, "height" => CANVAS_HEIGHT }
    player.register  # Attach to EngineSync
    player
  end

  def on_open(transport, event)
    unless @engine_started
      # TODO: Figure out a way to do this initially instead of waiting for a first socket to be opened.
      EM.add_periodic_timer(1) do
        # Step game content forward by one tick
        intentions = @engine.next_step_intentions
        @engine.apply_intentions(intentions)
      end
      @engine_started = true
    end

    # Now, wait for login.
  end

  def on_close(transport, event)
  end

  def on_message(transport, event)
  end

  def on_error(transport, event)
    puts "Protocol error for player #{@player_by_transport[transport]}: #{event.inspect}"
  end
end

Demiurge::Createjs.record_traffic
Demiurge::Createjs.run GoodShip.new
