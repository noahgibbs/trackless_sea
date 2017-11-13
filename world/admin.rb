# The admin zone is basically annotations on things that aren't really
# part of the world directly, but are important: player accounts, game
# settings, various defaults and configuration.

# Player information can be stored here. In general, if you want
# information to stick around it needs a StateItem.  An "inert"
# StateItem just means it doesn't change on its own or take any
# actions.
inert "players"

zone "admin" do
  agent "player template" do
    # No position or location, so it's instantiable.

    # Special action that gets performed on character creation
    define_action("create", "engine_code" => true) do
      if ["bob", "angelbob", "noah"].include?(item.name)
        item.state["admin"] = true
      end
    end

    # Special action that gets performed by the agent on character login
    define_action("login", "engine_code" => true) do
      raise("Called login on a non-player item!") unless @item.name["_player_agent"]
      item.state["player"] = item.name[0..-14]  # Remove "_player_agent" from the end of the name
      player_item = engine.item_by_name("players")
      current_position = player_item.state["active_position"]
      player_item.state.delete "active_position" # Delete the old active position
      if current_position
        item.move_to_position(current_position)
      else
        x, y = engine.item_by_name("start location").tmx_object_coords_by_name("start location")
        item.move_to_position "start location##{x},#{y}"
      end
    end

    define_action("logout") do
      player_state["active_position"] = item.position
      # Logged out? Teleport the player's agent to the "admin" zone,
      # in a sort of suspended animation.
      teleport_instant("admin")
    end

    define_action("move", "tags" => ["player_action", "agent_action"]) do |direction|
      # Just a straight-up move-immediately-if-possible, no frills.
      move_instant(direction)
    end

    define_action("statedump", "tags" => ["admin", "player_action"]) do
      dump_state
    end

    display do
      manasource_humanoid do
        layers "skeleton", "darkblonde_female"
      end
    end
  end
end
