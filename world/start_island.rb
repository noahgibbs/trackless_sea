zone "trackless island", "type" => "TmxZone" do
  tmx_location "start location" do
    manasource_tile_layout "tmx/trackless_island_main.tmx"
    description "A Mysterious Island"
  end

  agent "player template" do
    # No position, so it's instantiable.
    display do
      manasource_humanoid do
        layers "skeleton", "darkblonde_female"
      end
    end
  end
end
