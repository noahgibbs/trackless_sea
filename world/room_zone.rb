zone "trackless island" do
  type "TmxZone"

  tmx_location "front halls" do
    manasource_tile_layout "tmx/front_halls.tmx"
    description "In a Surreally Huge Hall of a Large, Dreamlike Tower"

  end

  agent "wanderer" do
    type "WanderingAgent"
    state.position = "start location#27,27"

    display do
      manasource_humanoid do
        layers "skeleton", "darkblonde_female"
      end
    end
  end

  agent "wanderer2" do
    type "WanderingAgent"
    state.position = "start location#30,30"
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

  agent "wanderer3" do
    type "WanderingAgent"
    state.position = "start location#33,33"
    state.wander_every = 5

    display do
      manasource_humanoid do
        layers "female", "robe_female", "darkblonde_female", "gold_tiara_female"
      end
    end
  end
end
