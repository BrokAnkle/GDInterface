@tool
extends EditorPlugin

var interface_inspector: Control

func _enable_plugin() -> void:
	add_autoload_singleton("GDInterface", "res://addons/gd-interface/gdinterface.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton("GDInterface")


func _enter_tree() -> void:
	resource_saved.connect(on_resource_saved)
	# Initialiser l'inspecteur d'interfaces
	interface_inspector = preload("interface_inspector.gd").new()

	# S'enregistrer pour les sauvegardes de scripts
	get_editor_interface().get_script_editor().editor_script_changed.connect(_on_script_changed)

	# Vérifier tous les scripts au démarrage
	_check_all_scripts()

	print("GDInterface plugin activated")


func _exit_tree() -> void:
	if interface_inspector:
		interface_inspector.queue_free()
	print("GDInterface plugin deactivated")


func on_resource_saved(resource: Resource ) -> void:
	if resource is Script:
		_check_script(resource)


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
	var script_path = script.resource_path
	var source_code = script.source_code
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
	
		
		#TODO: Scan "Interfaces" folder (or user defined folder, or a control panel where user can put the interface's script)
		# Looking for Interface's child classes variables
		for type: InterfaceType in Interface.types:
			if line.begins_with("var ") and str(": ", type.type_name) in line:
				print("found an interface of type" + type.type_name)
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
	print("❌ [GDInterface] %s:%d - Variable '%s' - %s" % [script_path, line_number, var_name, message])
