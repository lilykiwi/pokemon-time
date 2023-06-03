extends Node

# This node has a child; MapScroll
# Additionally, a child; Cursor
# Finally,      a child; CurrentLocationMarker

# MapScroll contains 3 layers; Background, Roads, Locations.
# Additionally, there are 14 Location nodes

# Cursor can move around the map, and can be used to select a location to fly to
# We should try and center the cursor on the screen, and move the map around it
# The map should always cover the screen (no black bars)
# When the map is unable to do this, move the cursor instead.

# This object is part of the main scene heirarchy and will be initialised when needed.


var mapScroll: Node2D = null
var cursor: AnimatedSprite2D = null

var currentLocationMarker: AnimatedSprite2D = null

var currentLocation: int = 0