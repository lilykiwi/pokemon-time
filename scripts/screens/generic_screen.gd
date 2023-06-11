class_name GenericScreen extends Node2D

var _state_manager:     StateManager = null
var _needs_subviewport: bool         = false

func _init(needs_subviewport) -> void:
  _state_manager     = null 
  _needs_subviewport = needs_subviewport

func register_state_manager(state_manager: StateManager) -> void:
  _state_manager = state_manager