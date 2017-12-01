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
TICKS_PER_SAVE = (60 * 1000 / TICK_MILLISECONDS)  # Every 1 minute

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

    # If we restore state, we should do it before the EngineSync is
    # created.  Otherwise we have to replay a lot of "new item"
    # notifications or otherwise register a bunch of state with the
    # EngineSync. TODO: make a state-restore give a notification
    # to allow the EngineSync to just roll with it.
    last_statefile = [ "state/shutdown_statefile.json", "state/periodic_statefile.json", "state/error_statefile.json" ].detect do |f|
      File.exist?(f)
    end
    if last_statefile
      STDERR.puts "Restoring state data from #{last_statefile.inspect}."
      state_data = MultiJson.load File.read(last_statefile)
      @engine.load_state_from_dump(state_data)
    end

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
    body = @engine.item_by_name(username)
    if body
      # If the body already exists, it should be marked as a player body
      raise("You can't create a body with reserved name #{username}!") unless body.state["$player_body"] == username
    else
      body = @engine.instantiate_new_item(username, @template, "position" => @start_position)
      body.state["$player_body"] = username
      body.run_action("create") if body.get_action("create")
    end
    body.run_action("login") if body.get_action("login")

    # And create a Demiurge::Createjs::Player for the player's viewpoint
    player = Demiurge::Createjs::Player.new websocket: websocket, name: username, demi_item: body, engine_sync: @engine_sync, width: CANVAS_WIDTH, height: CANVAS_HEIGHT

    player.message "displayInit", { "width" => CANVAS_WIDTH, "height" => CANVAS_HEIGHT, "ms_per_tick" => TICK_MILLISECONDS }
    player.register  # Attach to EngineSync
    player
  end

  def on_player_logout(websocket, player)
    body = @engine.item_by_name(player.name)
    body.run_action("logout") if body && body.get_action("logout")
  end

  def on_player_action_message(websocket, action_name, *args)
    STDERR.puts "Got player action: #{action_name.inspect} / #{args.inspect}"
    player = player_by_websocket(websocket) # LoginUnique defines player_by_websocket and player_by_name
    if action_name == "move"
      player.demi_item.queue_action "move", args[0]
      return
    end
    raise "Unknown player action #{action_name.inspect} with args #{args.inspect}!"
  end

  def run_engine
    return if @engine_started

    counter = 0
    EM.add_periodic_timer(0.001 * TICK_MILLISECONDS) do
      # Step game content forward by one tick
      begin
        @engine.advance_one_tick
        counter += 1
        if counter % TICKS_PER_SAVE == 0
          STDERR.puts "Writing periodic statefile, every #{TICKS_PER_SAVE.inspect} ticks..."
          ss = @engine.structured_state
          File.open("state/periodic_statefile.json", "w") do |f|
            f.print MultiJson.dump(ss, :pretty => true)
          end
        end
      rescue
        STDERR.puts "Error trace:\n#{$!.message}\n#{$!.backtrace.join("\n")}"
        STDERR.puts "Error when advancing engine state. Dumping state, skipping tick."
        ss = @engine.structured_state
        File.open("state/error_statefile.json", "w") do |f|
          f.print MultiJson.dump(ss, :pretty => true)
        end
      end
    end
    @engine_started = true
  end

  def on_open(transport, event)
    # TODO: Figure out a way to do this initially instead of waiting for a first socket to be opened.
    run_engine

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
