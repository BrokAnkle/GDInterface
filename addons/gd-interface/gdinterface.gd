extends Node


## Checks if the [param object] implements the interface [param interface_type]. If so, return true
func implements(object: Object, interface_type: InterfaceType) -> bool:
	for property in object.get_property_list():
		if property["class_name"] == interface_type.type_name:
			if (object.get(property["name"]) as Interface).contract.get_method().is_empty():
				push_warning(str(object.name, "does have the interface ", interface_type.type_name, "but it's not implemented."))
				return false
			return true
	return false

## Execute the given interface, if present in the given [param object] and pass to it [param args] as an Array of [Variant].[br]
## If you need to pass arguments, even only one, you MUST pass them in an array. If you don't need to pass argument you can leave it blank.
## (Reminder: if you don't give the right set of arguments in the right order, the interface will be ignored by the engine.)
func execute(object: Object, interface_type: InterfaceType, args: Array = []) -> Variant:
	for property in object.get_property_list():
		if property["class_name"] == interface_type.type_name:
			return (object.get(property["name"]) as Interface).execute(args)
	return null




## "Barbaric" methods if you prefer using interfaces in a less stricting way.
## Instead of using [Interface] and its child class, you can just call methods, signal or a callable set as object's metadata

## Checks if the given [param object], has method, signal or metadata of the given [param interface_name]. If so, return true
func implements_barbaric(object: Object, interface_name: String) -> bool:
	if object.has_meta(interface_name):
		return true
	elif object.has_method(interface_name):
		return true
	elif (object.has_signal(interface_name)
	and object.has_connections(interface_name)):
		return true
	else: return false


## Execute the given method, signal or metadata as [Callable] [param interface_name] if the [param object] has it. If not, just push a warning in the console.[br]
## This version doesn't take paramaters to pass to the "interface".[br]
## (Reminder: if you don't give the right set of arguments in the right order, the interface will be ignored by the engine.)
func execute_no_args(object: Object, interface_name: String) -> Variant:
	if object.has_meta(interface_name):
		if object.get_meta(interface_name) is Callable:
			return (object.get_meta(interface_name) as Callable).call()
	if object.has_method(interface_name):
		return object.call(interface_name)
	if (object.has_signal(interface_name)
	and object.has_connections(interface_name)):
		object.emit_signal(interface_name)
		return OK
	if implements_barbaric(object, interface_name):
		push_warning(str(object.name, " implement ", interface_name, "but couldn't execute"))
	else: push_warning(str(object.name, " doesn't implement ", interface_name))
	return null


## Execute the given method, signal or metadata as [Callable] [param interface_name] if the [param object] has it. If not, just push a warning in the console.[br]
## This version take paramaters to pass to the "interface" as a variadic set of arguments.[br]
## (Reminder: if you don't give the right set of arguments in the right order, the interface will be ignored by the engine.)
func execute_with_args(object: Object, interface_name: String, args: Array = []) -> Variant:
	if object.has_meta(interface_name):
		if object.get_meta(interface_name) is Callable:
			return (object.get_meta(interface_name) as Callable).callv(args)
	if object.has_method(interface_name):
		return object.callv(interface_name, args)
	if object.has_connections(interface_name):
		object.emit_signal(interface_name, args)
		return OK
	if implements_barbaric(object, interface_name):
		push_warning(str(object.name, " implement ", interface_name, "but couldn't execute"))
	else: push_warning(str(object.name, " doesn't implement ", interface_name))
	return null
