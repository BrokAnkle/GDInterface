@tool
extends Node

var consumable: Consumable
@export_tool_button("button") var button = function

func _ready() -> void:
	print("hi")

func function() -> void:
	print("hello")
	print(ProjectSettings.get_setting("plugins/gdinterface/interface_paths"))
	print(ProjectSettings.get_setting("plugins/gdinterface/interface_folder"))
	ProjectSettings.set_setting("plugins/gdinterface/interface_paths", "res://consumable.gd")
