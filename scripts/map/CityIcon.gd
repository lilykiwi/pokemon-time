extends Sprite2D

@export
var visitedSprite: Texture2D = null
@export
var unvisitedSprite: Texture2D = null

@export
var destinationName: String = ""
@export
var destinationDescription: String = ""

@export
var visited: bool = false
@export_range(0, 14)
var cityNumber: int = 0
var visitedBitmask: int = 0b000000000000000
# 1 bit for each location. This value is ANDed with the player's visited bitmask to determine if the player has visited this location.
@export
var alwaysVisited: bool = false

func _init():
  if alwaysVisited:
    visited = true
    visitedBitmask = 0b000000000000000
  else:
    visitedBitmask = 1 << cityNumber