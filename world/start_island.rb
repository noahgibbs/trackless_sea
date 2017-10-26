zone "trackless island" do
  type "TmxZone"

  tmx_location "start location" do
    manasource_tile_layout "tmx/trackless_island_main.tmx"
    description "A Mysterious Island"
  end

  agent "player surrogate" do
    #type "WanderingAgent"
    state.position = "start location#28,29"

    display do
      manasource_humanoid do
        layers "skeleton", "darkblonde_female"
      end
    end
  end
end
