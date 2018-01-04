unless window.Trackless?
  class window.Trackless

class window.Trackless.UI
  constructor: () ->

  message: (msgName, argArray) ->
    console.log "Got UI message:", msgName, argArray

    messageMap = {
      "uiActions": "actions",
    }
    handler = messageMap[msgName]
    unless handler?
      console.warn "Couldn't handle message type #{msgName}!"
      return
    this[handler](argArray...)

  actions: (actions) ->
    console.log "Got list of actions:", actions

    # Remove the previous <li> elements and replace them
    dom_elts = $(".action_list")
    max_shared_index = Math.min(actions.length, dom_elts.length) - 1

    if max_shared_index > 0
      for index in [0..max_shared_index]
        dom_elts[index].html("<li data-action='#{actions[index]}}'>#{actions[index]}</li>")

    if actions.length > dom_elts.length
      actions_only_index = max_shared_index + 1
      for index in [actions_only_index .. (actions.length - 1)]
        dom_elts.append("<li data-action='#{actions[index]}}'>#{actions[index]}</li>")
    else if dom_elts.length > actions.length
      dom_only_index = max_shared_index + 1
      for index in [(dom_elts.length - 1) .. dom_only_index] # Iterate highest to lowest
        dom_elts[index].remove()
