#extends GenericButton
#
#var loader
#var time_max
#var load_target
#var scene_path
#var status
#
## Called when the node enters the scene tree for the first time.
#func _ready():
#  self.pressed.connect(self.button_pressed)
#
#func button_pressed():
#  # get the scene from our meta
#  scene_path = self.get_meta("Scene")
#
#  # this is a loader, so we can hide the debug overlay. find node called DebugOverlay
#  var debug_overlay = get_node("%DebugOverlay")
#  debug_overlay.hide()
#
#  # grab the node and clear it
#  load_target = get_node("%LoadTarget")
#
#  # initilise the loader
#  status = ResourceLoader.load_threaded_request(scene_path.get_path(), "PackedScene", false)
#  if status != OK:
#    print("Failed to load scene: " + scene_path.get_path())
#    print("Error: " + str(status))
#    return
#  else:
#    print("Loading scene: " + scene_path.get_path())
#    set_process(true)
#
#func _process(_time):
#  if status == null:
#    # no need to process anymore
#    set_process(false)
#    return
#
#  while true:
#    status = ResourceLoader.load_threaded_get_status(scene_path.get_path())
#    if status == ResourceLoader.THREAD_LOAD_LOADED: # Finished loading.
#      print("Loaded scene: " + scene_path.get_path())
#      var resource = ResourceLoader.load_threaded_get(scene_path.get_path())
#      status = null
#      # instantiate
#      load_target.add_child(resource.instantiate())
#      break
#    elif status == ResourceLoader.THREAD_LOAD_IN_PROGRESS: # Still loading.
#      print(ResourceLoader.load_threaded_get_status(scene_path.get_path()))
#    else: # Error during loading. THREAD_LOAD_INVALID_RESOURCE or THREAD_LOAD_FAILED 
#      print("Error loading scene: " + str(status))
#      status = null
#      break
#
