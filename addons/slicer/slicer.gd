@tool
extends EditorPlugin

# initialise dock as a ui control
var dock: Control = null

var xSliceBox: SpinBox = null
var ySliceBox: SpinBox = null

var resourcePicker: EditorResourcePicker = null

var itemFlowContainer: HFlowContainer = null

var exportToNewFolder: CheckButton = null
var exportNextTo: CheckButton = null
var folderName: LineEdit = null

var exportButton: Button = null

# ---------------------------------------------------------------------------------------------------------------------

func _enter_tree():
  
  # initialise the dock
  dock = Control.new()
  dock.set_name("Slicer")
  dock.clip_contents = true
  dock.set_h_size_flags(Control.SIZE_EXPAND_FILL)
  dock.set_v_size_flags(Control.SIZE_EXPAND_FILL)

  # add a hboxcontainer to the dock
  var hbox: HBoxContainer = HBoxContainer.new()
  hbox.set_anchors_preset(Control.PRESET_FULL_RECT) 
  dock.add_child(hbox)

  # add a vboxcontainer to the hbox
  var sidebar: VBoxContainer = VBoxContainer.new()
  sidebar.set_h_size_flags(Control.SIZE_SHRINK_BEGIN)
  sidebar.set_v_size_flags(Control.SIZE_EXPAND_FILL)
  hbox.add_child(sidebar)

  # add an HFlowContainer to the hbox
  itemFlowContainer = HFlowContainer.new()
  itemFlowContainer.set_h_size_flags(Control.SIZE_EXPAND_FILL)
  itemFlowContainer.set_v_size_flags(Control.SIZE_EXPAND_FILL)

  hbox.add_child(itemFlowContainer)

  # add a resource picker to the sidebar
  add_resource_picker(sidebar)

  # add spinboxes to the sidebar
  add_spinbox_controls(sidebar)

  # add a slice button to the sidebar
  add_slice_button(sidebar)

  # add an export button to the sidebar
  add_export_button(sidebar)

  add_control_to_bottom_panel(dock, "Slicer")

# -- exit tree --------------------------------------------------------------------------------------------------------

func _exit_tree():
  # Clean-up of the plugin goes here.
  remove_control_from_bottom_panel(dock)

# -- spinbox controls -------------------------------------------------------------------------------------------------

func add_spinbox_controls(sidebar):

  # add a hboxcontainer to the sidebar
  var hbox: HBoxContainer = HBoxContainer.new()
  hbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)

  # add a vboxcontainer to the hbox
  var xSliceCount: VBoxContainer = VBoxContainer.new()
  var ySliceCount: VBoxContainer = VBoxContainer.new()
  xSliceCount.set_h_size_flags(Control.SIZE_EXPAND_FILL)
  ySliceCount.set_h_size_flags(Control.SIZE_EXPAND_FILL)

  var xSliceLabel: Label = Label.new()
  xSliceLabel.set_text("X Slices")
  xSliceLabel.set_h_size_flags(Control.SIZE_EXPAND_FILL)
  var ySliceLabel: Label = Label.new()
  ySliceLabel.set_text("Y Slices")
  ySliceLabel.set_h_size_flags(Control.SIZE_EXPAND_FILL)

  xSliceBox = SpinBox.new()
  xSliceBox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
  xSliceBox.set_min(1)
  xSliceBox.set_max(9999) # why go this high?
  xSliceBox.set_value(1)
  ySliceBox = SpinBox.new()
  ySliceBox.set_min(1)
  ySliceBox.set_max(9999) # why go this high?
  ySliceBox.set_value(1)

  xSliceCount.add_child(xSliceLabel)
  xSliceCount.add_child(xSliceBox)

  ySliceCount.add_child(ySliceLabel)
  ySliceCount.add_child(ySliceBox)

  hbox.add_child(xSliceCount)
  hbox.add_child(ySliceCount)
  
  sidebar.add_child(hbox)

# -- resource picker --------------------------------------------------------------------------------------------------

func add_resource_picker(sidebar):

  # add a label
  var label: Label = Label.new()
  label.set_text("Resource")
  sidebar.add_child(label)

  # add a resource picker
  resourcePicker = EditorResourcePicker.new()
  resourcePicker.set_h_size_flags(Control.SIZE_EXPAND_FILL)
  resourcePicker.base_type = "CompressedTexture2D"
  sidebar.add_child(resourcePicker)

# -- slice buttons ----------------------------------------------------------------------------------------------------

func add_slice_button(sidebar):
  # add a new hboxcontainer to the sidebar
  var hbox: HBoxContainer = HBoxContainer.new()
  hbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
  sidebar.add_child(hbox)

  # add a button
  var sliceButton: Button = Button.new()
  sliceButton.set_text("Slice")
  sliceButton.connect("pressed", _on_slice_button_pressed)
  sliceButton.set_h_size_flags(Control.SIZE_EXPAND_FILL)
  hbox.add_child(sliceButton)

  # add a clear button
  var clearButton: Button = Button.new()
  clearButton.set_text("x")
  clearButton.connect("pressed", _on_clear_button_pressed)
  clearButton.set_h_size_flags(Control.SIZE_SHRINK_CENTER)
  hbox.add_child(clearButton)

# -- export button ----------------------------------------------------------------------------------------------------

func add_export_button(sidebar):
  # add a horizontal divider
  var divider: HSeparator = HSeparator.new()

  # add a checkbox for exporting to a new folder
  exportToNewFolder = CheckButton.new()
  exportToNewFolder.set_text("Export to new Folder")
  exportToNewFolder.set_h_size_flags(Control.SIZE_EXPAND_FILL)
  exportToNewFolder.connect("toggled", _on_export_folder_toggle)

  # add an input box for the folder name
  folderName = LineEdit.new()
  folderName.set_h_size_flags(Control.SIZE_EXPAND_FILL)
  folderName.placeholder_text = "Folder Name"
  # disable it by default
  folderName.editable = false

  # add an export button
  exportButton = Button.new()
  exportButton.set_text("Export")
  exportButton.connect("pressed", _on_export_button_pressed)
  # disable it by default
  exportButton.set_disabled(true)

  sidebar.add_child(divider)
  sidebar.add_child(exportToNewFolder)
  sidebar.add_child(folderName)
  sidebar.add_child(exportButton)

# -- slice button -----------------------------------------------------------------------------------------------------

func _on_slice_button_pressed():

  if itemFlowContainer.get_child_count() > 0:
    _on_clear_button_pressed()

  # Called when the button is pressed.
  var x = xSliceBox.get_value()
  var y = ySliceBox.get_value()

  var texture = resourcePicker.edited_resource

  if texture == null:
    return

  for j in range(y):
    for i in range(x):
      # create a rect based on the slice count and texture size
      var rect = Rect2(i * texture.get_width() / x, j * texture.get_height() / y, texture.get_width() / x, texture.get_height() / y)

      # create an atlas texture
      var atlasTexture = AtlasTexture.new()
      atlasTexture.set_atlas(texture)
      atlasTexture.region = rect

      # check if the texture is empty
      var imageData = atlasTexture.get_image().get_used_rect()
      if imageData.size.x == 0 or imageData.size.y == 0:
        continue

      # create a texture rect and add it to the flow container
      var textureRect = TextureRect.new()
      textureRect.set_texture(atlasTexture)
      textureRect.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT)
      textureRect.scale = rect.size * 2

      itemFlowContainer.add_child(textureRect)

  if itemFlowContainer.get_child_count() > 0:
    exportButton.set_disabled(false)
  


# -- clear button -----------------------------------------------------------------------------------------------------

func _on_clear_button_pressed():
  if itemFlowContainer.get_child_count() == 0:
    return

  for item in itemFlowContainer.get_children():
    item.free()

  exportButton.set_disabled(true)

# -- export -----------------------------------------------------------------------------------------------------------

func _on_export_button_pressed():
  # Called when the button is pressed.

  # create a fileDialog for the user to select a folder
  var fileDialog = FileDialog.new()
  fileDialog.set_access(FileDialog.ACCESS_FILESYSTEM)
  fileDialog.file_mode = 2 # DIR

  # if the user selects a folder
  fileDialog.connect("dir_selected", _on_dir_selected)

  # show the fileDialog
  get_editor_interface().add_child(fileDialog)
  fileDialog.popup_centered(Vector2i(300, 700))

# -- toggle folder ----------------------------------------------------------------------------------------------------

func _on_export_folder_toggle(val):
  # Called when the button is pressed.
  folderName.editable = val

# -- dialogue done ----------------------------------------------------------------------------------------------------

func _on_dir_selected(dir):
  print(dir)

  # get the folder name
  if exportToNewFolder.is_pressed() and folderName.text != "":
    dir = dir + "/" + folderName.text
  
  if not dir.ends_with("/"):
    #print("adding /")
    dir = dir + "/"

  if itemFlowContainer.get_child_count() == 0:
    print("No textures to export. error?")
    return

  if DirAccess.open(dir) == null:
    print("Error opening directory: " + dir)
    print("Attempting to create directory: " + dir)
    if DirAccess.make_dir_absolute(dir) != OK:
      print("Error creating directory: " + dir)
      return

  # get the textures
  var textures = []
  for item in itemFlowContainer.get_children():
    textures.append(item.get_texture())

  # export the textures as AtlasTextures
  for i in range(textures.size()):
    var path = dir + str(i) + ".tres"
    if ResourceSaver.save(textures[i], path) != OK:
      print("Error saving texture: " + path)
