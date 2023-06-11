extends TextureButton

var last = 0
var labelChild: Label = null

signal draw_mode_changed

@export
var offset = 8
@export
var offsetPressed = 6

func _ready():
  labelChild = get_child(0) # !!! assuming the label is the first child

# every frame
func _process(_delta):
  var temp = get_draw_mode()
  if last == temp:
    return # no change
  if labelChild == null:
    return # no label
  else:
    emit_signal("draw_mode_changed", self, temp)
  match temp:
    DRAW_DISABLED, DRAW_NORMAL, DRAW_HOVER:
      # check if the label is offset
      if labelChild.position.y != offset:
        # reset the label
        labelChild.position.y = offset
    DRAW_HOVER_PRESSED, DRAW_PRESSED:
      # check if the label is offset
      if labelChild.position.y != offsetPressed:
        # reset the label
        labelChild.position.y = offsetPressed

  last = get_draw_mode()
