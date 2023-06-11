class_name wDoor extends Node2D

# we hold a variable of what scene this door points to, and a variable of what door in that scene

@export var sceneRef: PackedScene = null
@export var doorRef: int = 0

# finally, we hold a Sprite2D with a set of frames for the door animation
@export var doorSprite: Sprite2D = null


# we can assume that we hold a node2d child called spawnpoint. we hold a variable for that.
# this is where the player will spawn when they enter the door. it's effecitevly an empty object.
var spawnpoint: Node2D = null