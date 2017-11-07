# The admin zone is basically annotations on things that aren't really
# part of the world directly, but are important: player accounts, game
# settings, various defaults and configuration.

inert "players"  # The default engine-account plugin stores account information here.

zone "admin" do
  agent "player template" do
    # No position, so it's instantiable.

    define_action("move") do |direction|
      # Just a straight-up move-immediately-if-possible, no frills.
      move_instant(direction)
    end

    display do
      manasource_humanoid do
        layers "skeleton", "darkblonde_female"
      end
    end
  end
end
