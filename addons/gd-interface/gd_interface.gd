@tool
extends EditorPlugin


var interface_dock: Control

var interface_folder_path: String
#var interface_scripts_paths: PackedStringArray
## Contains the type of [Interface] child class (class_name * extends Interface)
var interface_types: Array[String]

func _enable_plugin() -> void:
	add_autoload_singleton("GDInterface", "res://addons/gd-interface/gdinterface.gd")
	ProjectSettings.settings_changed.connect(on_settings_changed)



func _disable_plugin() -> void:
	remove_autoload_singleton("GDInterface")


func _enter_tree() -> void:
	resource_saved.connect(on_resource_saved)
	
	interface_dock = preload("res://addons/gd-interface/Dock/gd_interface_dock.tscn").instantiate()
	add_control_to_bottom_panel(interface_dock, "GDInterface")
	
	get_editor_interface().get_script_editor().editor_script_changed.connect(_on_script_changed)

	_check_all_scripts()
	print_rich("[color=white]GDInterface plugin activated")


func _exit_tree() -> void:
	if interface_dock:
		remove_control_from_bottom_panel(interface_dock)
		interface_dock.queue_free()
	print_rich("[color=white]GDInterface plugin deactivated")


func on_settings_changed() -> void:
	# Update Folder Path
	interface_folder_path = ProjectSettings.get_setting("plugins/gdinterface/interface_folder")
	
	#Update Individual Scripts Path
	#var script_paths_string: String = ProjectSettings.get_setting("plugins/gdinterface/interface_paths")
	#interface_scripts_paths = script_paths_string.split(";")


func on_resource_saved(resource: Resource) -> void:
	print("resource saved")
	if resource is Script:
		print("resource is script")
		# Get all interface types from interface folder
		interface_types = get_interfaces_script_files(interface_folder_path)
		print("interface types = ", interface_types)
		# Get interface types from individual scripts
		#if !interface_scripts_paths.is_empty():
			#for path in interface_scripts_paths:
				#if path.ends_with(".gd"):
					#var interface_class = extract_class_name(path)
					#if interface_class.is_empty():
						#push_error(str("Couldn't find Interface inheritance in ", path))
					#else:
						#print("interface_class", interface_class)
						#interface_types.push_back(interface_class)
		
		_on_script_changed(resource)


func get_interfaces_script_files(start_path: String) -> Array[String]:
	var interface_classes: Array[String]
	var dir := DirAccess.open(start_path)
	if dir:
		dir.include_hidden = false
		dir.include_navigational = false
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = start_path.path_join(file_name)
			if dir.current_is_dir():
				interface_classes.append_array(get_interfaces_script_files(full_path))
			elif file_name.ends_with(".gd"):
				var interface_class_name := extract_class_name(full_path)
				if !interface_class_name.is_empty():
					interface_classes.push_back(interface_class_name)
					
			file_name = dir.get_next()
	
	return interface_classes


func extract_class_name(script_path: String) -> String:
	var script := FileAccess.open(script_path, FileAccess.READ)
	if script:
		var source_code := script.get_as_text()
		var class_name_index := source_code.find(" extends Interface")
		# We found that the script inherits from Interface
		# Do not take acount for "exends Interface" that are
		# far in the code. It could be comments or texts
		if class_name_index >= 0 and class_name_index <= 50:
			var interface_class: String
			# Remove the whitespace with "-1"
			var i = class_name_index - 1
			# Until we get a whitespace, keep moving back in the code
			while source_code[i] != " ":
				interface_class += source_code[i]
				i-= 1
				# By going backward we filled the string in reverse, so reverse it again
			interface_class = interface_class.reverse()
			return interface_class
	return ""


func _on_script_changed(script: Script) -> void:
	_check_script(script)


func _check_all_scripts() -> void:
	var script_files = _get_all_script_files("res://")
	for script_path in script_files:
		var script = load(script_path)
		if script and script is GDScript:
			_check_script(script)


func _get_all_script_files(path: String) -> Array[String]:
	var script_files: Array[String] = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name == "." or file_name == "..":
				file_name = dir.get_next()
				continue
			var full_path = path.path_join(file_name)
			if dir.current_is_dir():
				script_files.append_array(_get_all_script_files(full_path))
			elif file_name.ends_with(".gd"):
				script_files.append(full_path)
			file_name = dir.get_next()
	return script_files


func _check_script(script: Script) -> void:
	var script_path: String = script.resource_path
	var source_code: String = script.source_code
	# scan the script's source code for Interface variables
	var interface_vars = _find_interface_variables(source_code)
	for var_info in interface_vars:
		_validate_interface_variable(script_path, var_info)


func _find_interface_variables(source_code: String) -> Array[Dictionary]:
	var variables: Array[Dictionary] = []
	var lines = source_code.split("\n")
	var current_class = ""
	var in_class = false
	var brace_count = 0
	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		var line_number = i + 1
		# Class detection
		if line.begins_with("class "):
			current_class = line.replace("class ", "").split(":")[0].strip_edges()
			in_class = true
			brace_count = 0
		elif line.contains("{"):
			brace_count += line.count("{")
		elif line.contains("}"):
			brace_count -= line.count("}")
			if brace_count <= 0 and in_class:
				in_class = false
				current_class = ""
	
		for type: String in interface_types:
			if line.begins_with("var ") and str(": ", type) in line:
				print_rich("[color=yellow]found an interface of type " + type)
				var var_name = line.replace("var ", "").split(":")[0].strip_edges()
				var assignment_part = line.split("=")
				var has_assignemnt = assignment_part.size() > 1
				variables.append({
					"line_number": line_number,
					"variable_name": var_name,
					"class_name": current_class,
					"has_assignment": has_assignemnt,
					"assignment_value": assignment_part[1].strip_edges() if has_assignemnt else "",
					"full_line": line
				})
	return variables


func _validate_interface_variable(script_path: String, var_info: Dictionary) -> void:
	var line_number = var_info["line_number"]
	var var_name = var_info["variable_name"]

	# Check if variable has a valid assignation
	if not var_info["has_assignment"]:
		_report_error(script_path, line_number, var_name, "Interface variable '%s' must be assigned with a valid callable." % var_name)
		return
	var assignment = var_info["assignment_value"]
	#Basics callable check
	if assignment == "null":
		_report_error(script_path, line_number, var_name, "Interface variable '%s' can't be null." % var_name)
	elif assignment.begins_with("Callable(") and assignment.ends_with(")"):
		#Check callable content
		var callable_content = assignment.substr(9, assignment.length() - 10)
		if callable_content.is_empty() or callable_content == "null":
			_report_error(script_path, line_number, var_name, "Interface's Callable '%s' can't be empty or null." % var_name)
		elif assignment == "Interface.new()":
			_report_error(script_path, line_number, var_name, "Interface variable '%s' must have a valid callable, not solely Interface.new()." % var_name)


func _report_error(script_path: String, line_number: int, var_name: String, message: String) -> void:
	# Create error in Godot Editor
	push_error("ERROR Interface: %s:%d - %s" % [script_path, line_number, message])
	# Show also in console
	print_rich("[color=red]❌ [GDInterface] %s:%d - Variable '%s' - %s" % [script_path, line_number, var_name, message])
