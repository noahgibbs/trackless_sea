unless window.Trackless?
  class window.Trackless

class window.Trackless.Simulation extends DCJS.Simulation
  notification: (data) ->
    console.log "Trackless received a notification!", data
