extends ReferenceRect

func _unhandled_input(event):
  if event is InputEventKey:
    if event.is_pressed() and event.is_action_pressed("debug_menu"):
      # hide or unhide the Debug Overlay
      if not self.visible:
        self.show()
      else:
        self.hide()
