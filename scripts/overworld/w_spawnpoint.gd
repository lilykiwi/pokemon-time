@tool
class_name wSpawnpoint extends Sprite2D

## wSpawnpoint - A world spawnpoint which can be used to spawn the player at a location
##
## This is used by the StateManager and LocaleManager to spawn the player at the right
## location upon entering a new state/locale. Additionally, this is used when the player
## steps through a door in the same location, and the player should be spawned at the
## other side of the door/staircase.

enum Direction {
  UNSET, # same as before
  UP,    # point upwards
  RIGHT, # point right
  DOWN,  # point downwards
  LEFT,  # point left
}

@export_category("Spawnpoint Properties")
@export var direction: Direction = Direction.UNSET
var _prevDirection: Direction = Direction.UNSET

# this script should be on a prefab with a texture from Sprites/Overworld/debug/tiles.png.
# this image has various tiles in an 8x8 grid, each frame corresponding with another debug marker.

# Direction.UNSET is frame 19
# Direction.UP    is frame 20
# Direction.RIGHT is frame 21
# Direction.DOWN  is frame 22
# Direction.LEFT  is frame 23

func _process(delta):
  if Engine.is_editor_hint():
    if direction != _prevDirection:
      self.frame = 19 + direction
      _prevDirection = direction
