module Demiurge
  class AgentBlockRunner
    # This returns a block of player-specific state which can be used
    # for settings.  TODO: figure out how to do this in a
    # game-agnostic way that doesn't depend on a world file declaring
    # an "inert 'player'" StateItem. Also, this state is saved and
    # restored with the engine state, not with external player
    # settings, if the application has any.
    def player_state
      return unless item.state["player"]  # Only allow setting player state in a player agent's block runner.

      player_item = engine.item_by_name("players")
      player_item.state[item.state["player"]] ||= {}  # Allocate player settings for this player name
    end
  end
end
