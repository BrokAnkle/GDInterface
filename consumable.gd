class_name Consumable extends Interface

func _init(implementation: Callable) -> void:
	super(implementation)
	type = InterfaceType.new(self.get_class())
	types[self.get_class()] = type


func get_class() -> String:
	return "Consumable"
