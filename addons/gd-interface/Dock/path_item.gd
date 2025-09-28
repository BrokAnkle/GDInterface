#@tool
#extends MarginContainer
#
#@onready var path_line_edit: LineEdit = %PathLineEdit
#@onready var validate_button: Button = %ValidateButton
#
#var path: String
#var just_changed_settings: bool = false
#
#func _ready() -> void:
	#validate_button.hide()
	#path_line_edit.text = path
	#ProjectSettings.settings_changed.connect(on_settings_changed)
#
#
### If in the settings, the path of this item has been removed, delete the item.
#func on_settings_changed() -> void:
	#if !just_changed_settings:
		#var paths_string: String = ProjectSettings.get_setting("plugins/gdinterface/interface_paths", "")
		#if !paths_string.contains(path):
			#queue_free()
	#just_changed_settings = false
#
#
#func _on_validate_button_pressed() -> void:
	#var file_path: String = path_line_edit.text.replace('"', "").strip_edges()
	#var paths: String = save_path(path_line_edit.text)
	#if paths.is_empty():
		#path_line_edit.clear()
		#path_line_edit.placeholder_text = str("The file ", file_path, " already registered or path invalid.")
		#path_line_edit.add_theme_color_override("font_placeholder_color", Color("df000099"))
	#else:
		## print information that the interfacet has been registered
		#print(str("New interface script has been registered to path ", file_path,". GDInterface will use the classe of this file to generate error if non-implemented interfaces are found."))
		#path_line_edit.add_theme_color_override("font_color", Color.GREEN)
		#path_line_edit.text = file_path
	#
	#validate_button.hide()
#
#
#func _on_delete_button_pressed() -> void:
	#var paths_string: String = ProjectSettings.get_setting("plugins/gdinterface/interface_paths", "")
	#if !paths_string.is_empty():
		#if paths_string.contains(path):
			#paths_string = paths_string.replace(str(path, ";"), "")
			#print(str("new path string after deletion of :", path, " = ", paths_string))
			#ProjectSettings.set_setting("plugins/gdinterface/interface_paths", paths_string)
		#
	#queue_free()
#
#
#func _on_path_line_edit_text_changed(new_text: String) -> void:
	#validate_button.show()
	#validate_button.disabled = true
	#
	#path_line_edit.add_theme_color_override("font_color", Color.WHITE)
	#path_line_edit.add_theme_color_override("font_placeholder_color", Color("dfdfdf99"))
	#path_line_edit.placeholder_text = "Enter path of an interface class file"
	#
	#path_line_edit.add_theme_color_override("font_color", Color.RED)
	#var file_path: String = new_text.replace('"',"").strip_edges()
	#if file_path.ends_with(".gd"):
		#var file := FileAccess.open(file_path, FileAccess.READ)
		#if file:
			#var code: String = file.get_as_text()
			#if code.contains("extends Interface"):
				#validate_button.disabled = false
				#path_line_edit.add_theme_color_override("font_color", Color.GREEN)
#
#
#
#func _on_path_line_edit_text_submitted(new_text: String) -> void:
	## clean the submitted text
	#var file_path: String = new_text.replace('"', "").strip_edges()
	#var paths: String = save_path(file_path)
	## check if path is valid
	##if paths.is_empty():
		##path_line_edit.clear()
		##path_line_edit.placeholder_text = str("The file ", file_path, " already registered or path invalid.")
		##path_line_edit.add_theme_color_override("font_placeholder_color", Color("df000099"))
	##else:
		### print information that the interface has been registered
		##print(str("New interface script has been registered to path ", file_path,". GDInterface will use the classe of this file to generate error if non-implemented interfaces are found."))
		##path_line_edit.add_theme_color_override("font_color", Color.GREEN)
		##path_line_edit.text = file_path
	##
	##validate_button.hide()
#
#
### Try to check if the given path can be added to existing paths, and return them, or an empty string if couldn't validate
#func save_path(path: String) -> String:
	## clean file path
	#var file_path: String = path.replace('"',"").strip_edges()
	## validate file path
	#if validate_file(path):
		#var paths: String = ProjectSettings.get_setting("plugins/gdinterface/interface_paths", "")
		### check if file path already registered in the settings
		#if !paths.contains(file_path):
			### if there is no file path already registered, create the first one
			#if paths.is_empty():
				#paths = file_path
			### otherwise, add the file path to the others, separate them with a coma (";")
			#else:
				#paths += str(";", file_path)
			#path_line_edit.add_theme_color_override("font_color", Color.GREEN)
			#path_line_edit.text = file_path
			### save in the Project Settings
			#just_changed_settings = true
			#ProjectSettings.set_setting("plugins/gdinterface/interface_paths", paths)
			##return paths
		##path_line_edit.placeholder_text = str("The file ", file_path, " already registered.")
	##path_line_edit.placeholder_text = str("The file ", file_path, " is invalid: wrong path or not .gd or does not contains class that extends Interface.")
	#return ""
#
#func validate_file(file_path: String) -> bool:
	#file_path = file_path.replace('"', "").strip_edges()
	#if !file_path.ends_with(".gd"):
		#return false
	#
	#var script: Script = load(file_path)
	#if script:
		#var code: String = script.source_code
		#if code.contains("extends Interface"):
			#return true
		#else: 
			#return false
	#else:
		#return false
