class_name Pickable extends Interface

func _init(implementation: Callable) -> void:
	super(implementation)
	type = InterfaceType.new(self.get_class())
	types[self.get_class()] = type

func get_class() -> String:
	return "Pickable"

static func get_interface_type() -> InterfaceType:
	return types["Pickable"]
