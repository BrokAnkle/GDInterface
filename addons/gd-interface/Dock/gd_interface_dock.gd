@tool
extends Control

#const PATH_ITEM_SCENE: PackedScene = preload("res://addons/gd-interface/Dock/path_item.tscn")
#@onready var individual_path_box: VBoxContainer = %IndividualPathVBox
#@onready var add_button: Button = %AddButton

@onready var interface_folder_line_edit: LineEdit = %InterfaceFolderLineEdit
@onready var check_button: Button = %CheckButton

@onready var validate_code_check_box: CheckBox = %ValidateCodeCheckBox


#var paths: PackedStringArray


func _ready() -> void:
	check_button.disabled = true
	# Load the folder path from Project Settings
	var folder_path: String = ProjectSettings.get_setting("plugins/gdinterface/interface_folder", "res://interfaces")
	if folder_path.is_empty():
		folder_path = "res://interfaces"
	interface_folder_line_edit.text = folder_path
	
	validate_code_check_box.set_pressed_no_signal(ProjectSettings.get_setting("plugins/gdinterface/validate_code", true))
	
	# Load the individual interface paths from Project Settings and instantiate item for each
	#var interface_paths: String = ProjectSettings.get_setting("plugins/gdinterface/interface_paths", "")
	#if !interface_paths.is_empty():
		#paths = interface_paths.split(";")
		#for path in paths:
			#add_path_item(path)
	
	# Update the dock when Project Settings are modified
	ProjectSettings.settings_changed.connect(on_settings_changed)
	


#func _on_add_button_pressed() -> void:
	#add_path_item()


#func add_path_item(path: String = "") -> void:
	#var path_item = PATH_ITEM_SCENE.instantiate()
	#individual_path_box.add_child(path_item)
	#path_item.path = path


func on_settings_changed() -> void:
	# Folder path
	interface_folder_line_edit.text = str(ProjectSettings.get_setting("plugins/gdinterface/interface_folder", "res://interfaces"))
	
	# Individual paths
	# paths as a string, stored in Project Settings
	#var interface_paths: String = ProjectSettings.get_setting("plugins/gdinterface/interface_paths", "")
	#print("interface paths = ", interface_paths)
	#
	#
	#if interface_paths.is_empty():
		#paths = []
	#else:
		## convert the string into an array, the paths are separated by a coma (";")
		#var new_paths: Array[String] = Array(interface_paths.split(";"))
		## the paths before settings were changed
		#var old_paths : Array[String] = PackedStringArray(paths.duplicate())
		## paths to add, means the paths that are in "new_paths" but not in "old_paths"
		#var paths_to_add := PackedStringArray(new_paths.filter(func(p: String): return !p in old_paths))
		## paths to removed, means the paths that are in "old_paths" but not in "new_paths"
		#var paths_to_remove := PackedStringArray(new_paths.filter(func(p: String): return !p in new_paths))
		
		# remove the paths to remove
		#for path in paths_to_remove:
			#for path_item in individual_path_box.get_children():
				#if path_item.path == path:
					#path_item.queue_free()
		
		# add the paths to add
		#for path in paths_to_add:
			#add_path_item(path)
		
		# update the stored paths
		#paths = PackedStringArray(new_paths)


func _on_interface_folder_line_edit_text_changed(new_text: String) -> void:
	var folder_path: String = new_text.replace('"',"")
	if DirAccess.dir_exists_absolute(folder_path):
		interface_folder_line_edit.add_theme_color_override("font_color", Color.GREEN)
		check_button.disabled = false
	else:
		interface_folder_line_edit.add_theme_color_override("font_color", Color.RED)
		check_button.disabled = true


func _on_check_button_pressed() -> void:
	validate_folder_path()


func validate_folder_path() -> void:
	check_button.disabled = true
	var folder_path: String = interface_folder_line_edit.text.replace('"',"")
	if DirAccess.dir_exists_absolute(folder_path):
		ProjectSettings.set_setting("plugins/gdinterface/interface_folder", folder_path)
		print_rich(str("[color=green]GDInterface: Interface folder has been set to ", folder_path,". GDInterface will use the classes in this folder to generate error if non-implemented interfaces are found."))
		interface_folder_line_edit.add_theme_color_override("font_color", Color.GREEN)
	else:
		interface_folder_line_edit.text = ""
		interface_folder_line_edit.add_theme_color_override("font_color", Color.RED)
	

func _on_interface_folder_line_edit_text_submitted(new_text: String) -> void:
	if !check_button.disabled:
		validate_folder_path()


func _on_validate_code_check_box_toggled(toggled_on: bool) -> void:
	ProjectSettings.set_setting("plugins/gdinterface/validate_code", toggled_on)
	
