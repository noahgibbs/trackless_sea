# This file is required from config.ru

require "demiurge/dsl"
require "demiurge/tmx"

require "demiurge/createjs/engine_sync"
require "demiurge/createjs/json_accounts"
require "demiurge/createjs/login_unique"

# TODO: Set the HTML canvas from these? Or vice-versa?
CANVAS_WIDTH = 640
CANVAS_HEIGHT = 480
TICK_MILLISECONDS = 300

class GoodShip
  # Store player accounts in a JSON file
  include Demiurge::Createjs::JsonAccounts;
  # Only one login per player at a time
  include Demiurge::Createjs::LoginUnique;

  def initialize
    # Ruby extensions in the World Files? Load them.
    Dir["**/world/extensions/**/*.rb"].each do |ruby_ext|
      require_relative ruby_ext
    end
    @engine = Demiurge.engine_from_dsl_files *Dir["world/*.rb"]
    @engine_sync = Demiurge::Createjs::EngineSync.new(@engine)
    set_accounts_json_filename("accounts.json")

    @template = @engine.item_by_name("player template")
    raise("Can't find player template object!") unless @template
    @start_location = @engine.item_by_name("start location")
    start_obj = @start_location.tmx_object_by_name("start location")
    tilewidth = @start_location.tiles[:spritesheet][:tilewidth]
    tileheight = @start_location.tiles[:spritesheet][:tileheight]
    @start_position = "start location##{start_obj[:x] / tilewidth},#{start_obj[:y] / tileheight}"
  end

  def on_player_login(websocket, username)
    # Find or create a Demiurge agent as the player's body
    player_agent_name = "#{username}_player_agent"
    body = @engine.item_by_name(player_agent_name)
    unless body
      body = @engine.instantiate_new_item(player_agent_name, @template, "position" => @start_position)
      body.run_action("create") if body.get_action("create")
    end
    body.run_action("login") if body.get_action("login")

    # And create a Demiurge::Createjs::Player for the player's viewpoint
    player = Demiurge::Createjs::Player.new websocket: websocket, name: username, demi_agent: body, engine_sync: @engine_sync, width: CANVAS_WIDTH, height: CANVAS_HEIGHT

    player.message "displayInit", { "width" => CANVAS_WIDTH, "height" => CANVAS_HEIGHT, "ms_per_tick" => TICK_MILLISECONDS }
    player.register  # Attach to EngineSync
    player
  end

  def on_player_logout(websocket, player)
    player_agent_name = "#{player.name}_player_agent"
    body = @engine.item_by_name(player_agent_name)
    body.run_action("logout") if body && body.get_action("logout")
  end

  def on_player_action_message(websocket, action_name, *args)
    STDERR.puts "Got player action: #{action_name.inspect} / #{args.inspect}"
    player = player_by_websocket(websocket) # LoginUnique defines player_by_websocket and player_by_name
    if action_name == "move"
      player.demi_agent.queue_action "move", args[0]
      return
    end
    raise "Unknown player action #{action_name.inspect} with args #{args.inspect}!"
  end

  def on_open(transport, event)
    unless @engine_started
      # TODO: Figure out a way to do this initially instead of waiting for a first socket to be opened.
      EM.add_periodic_timer(0.001 * TICK_MILLISECONDS) do
        # Step game content forward by one tick
        intentions = @engine.next_step_intentions
        @engine.apply_intentions(intentions)
      end
      @engine_started = true
    end

    # Now, wait for login.
  end

  # Don't override on_close without calling super or the included LoginUnique module won't work right.
  def on_close(transport, event)
    super
  end

  def on_error(transport, event)
    puts "Protocol error for player #{@player_by_transport[transport]}: #{event.inspect}"
  end
end

Demiurge::Createjs.record_traffic
Demiurge::Createjs.run GoodShip.new
