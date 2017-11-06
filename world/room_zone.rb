zone "trackless island", "type" => "TmxZone" do
  tmx_location "front halls" do
    manasource_tile_layout "tmx/front_halls.tmx"
    description "In a Surreally Huge Hall of a Large, Dreamlike Tower"

  end

  agent "wanderer", "type" => "WanderingAgent" do
    state.position = "front halls#107,117"

    display do
      manasource_humanoid do
        layers "skeleton", "darkblonde_female"
      end
    end
  end

  agent "wanderer2", "type" => "WanderingAgent" do
    state.position = "front halls#115,120"
    state.wander_every = 1

    every_X_ticks("random speech", 6) do
      text = ["I am not a cow!", "That trick never works!", "Ooh, a penny!", "I hate Thursdays.", "I control what everyone says!", "Oof, my stomach hurts."]
      notification type: "speech", words: text.sample, duration: 5
    end

    display do
      manasource_humanoid do
        layers "male", "robe_male", "kettle_hat_male"
      end
    end
  end
end
