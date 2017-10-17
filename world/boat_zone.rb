zone "ship" do
  tmx_location "start location" do
    manasource_tile_layout "tmx/000-2-0.tmx"
    #manasource_tile_layout "tmx/evol-boat.tmx"
    description "Outside the Ship"

    # This is used only for the starting room
    state.start_x = 25
    state.start_y = 25

    state.bats = 0

    every_X_ticks("bat swarm", 5) do
      if state.bats == 0
        action description: "A huge swarm of bats flies toward the ship from some nearby hiding place. It churns around you, making it hard to see or hear."
        state.bats = 1
      else
        action description: "The bat swarm that had obscured the deck of the ship flies off, surprising you with sudden silence."
        state.bats = 0
      end
    end
  end

end
