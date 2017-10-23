zone "ship" do
  type "TmxZone"

  tmx_location "start location" do
    manasource_tile_layout "tmx/000-2-0.tmx"
    #manasource_tile_layout "tmx/evol-boat.tmx"
    description "Outside the Ship"

    state.bats = 0

    every_X_ticks("bat swarm", 25) do
      if state.bats == 0
        notification notification_type: "event", description: "A huge swarm of bats flies toward the ship from some nearby hiding place. It churns around you, making it hard to see or hear."
        state.bats = 1
      else
        notification notification_type: "event", description: "The bat swarm that had obscured the deck of the ship flies off, surprising you with sudden silence."
        state.bats = 0
      end
    end
  end

  agent "wanderer" do
    type "WanderingAgent"
    state.position = "start location"

    display do
      universal_humanoid do
        layers "skeleton", "robe_male"
      end
    end
  end
end
