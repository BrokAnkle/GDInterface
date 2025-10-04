class_name _CLASS_ extends Interface



func _init(implementation: Callable) -> void:
	contract = implementation
	type = InterfaceType.new(self.get_class())
	types[self.get_class()] = type


func get_class() -> String:
	return "_CLASS_"



static func get_interface_type() -> InterfaceType:
	return Interface.types["_CLASS_"]
