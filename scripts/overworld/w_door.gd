class_name wDoor extends Node2D

# we hold a variable of what scene this door points to, and a variable of what door in that scene

@export_category("Door Properties")
@export var scene: StateManager.Locations = StateManager.Locations.NONE
@export_range(0,999) var spawnpointID: int = 0
@export var isHidden: bool = false
@export var isLocked: bool = false

func _ready(): 
  if isHidden:
    # modulate our color
    self.modulate = Color(0,0,0,0)