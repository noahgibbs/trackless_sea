class Demiurge::ActionItemInternal::AgentBlockRunner
  # This returns a block of player-specific state which can be used
  # for settings.
  def player_state
    return unless item.state["player"]  # Only allow setting player state in a player agent's block runner.

    player_item = engine.item_by_name("players")
    player_item.state[item.state["player"]] ||= {}  # Allocate player settings for this player name
  end
end
