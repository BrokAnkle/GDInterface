class_name Interface extends Resource

## Base clase for Interface variables. Each class that use a variable of type
## Interface (and its inherited subclass), must signed the contact by feeding,
## the [member contract] variable. A variable of [Callable] that take the
## implemented method and will be executed when needed.

static var types: Dictionary = {} #{"Interface": InterfaceType.new("Interface")}
var type: InterfaceType = InterfaceType.new("Interface")
var contract: Callable

func _init(implementation: Callable) -> void:
	contract = implementation


## Override of the built-in function [method get_class][br]
## With no override, it returns the closest engine built-in class[br]
func get_class() -> String:
	return "Interface"


func execute(args: Array = []) -> Variant:
	if contract.get_argument_count() == 0:
		return contract.call()
	else:
		return contract.callv(args)


static func get_interface_type() -> InterfaceType:
	return types["Interface"]
