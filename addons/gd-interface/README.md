# GDInterface
GDInterface is a Godot 4.x script plugin that adds Object Oriented Programming interface feature into GDScript.

## How to use
### Create an interface

Create an interface by creating a new script that inherits from Interface class.
You **MUST** give it a *class_name*, override the *_init()* function and override the *get_class()* function and the static function *get_interface_type*.

In *_init()* simply do:
	super(implementation)
	type = InterfaceType.new(self.get_class())
	types[self.get_class()] = type

In *get_class()* just return the string of your class name

In *get_interface_type*, just return *Interface.types[self.get_class()]*

### Implement an interface

In the script you wish to implement an interface, create the function that will be executed by the interface.
Then create a variable of the type of your interface and give it the function as the argument in its constructor.
You can use arguments and return in your implementation.

### Execute an interface

Where you wish to execute an interface, use the **GDInterface** singleton.

You can check if the object you wish to call the interface from, actually implements it by using *GDInterface.implement* function.
It take the external object and the *InterfaceType* as arguments. It returns true if the the interface exists in the given object.

You execute the interface by using *GDInterface.execute* function.
Give it the object you wish to execute the interface from, and the *InterfaceType*. You can add the arguments to pass to the interface as an *Array*.

**Note: it is note mandatory to check if the interface is implemented, as *execute* will check again, and if the interface isn't implemented, it will do nothing**


#### Barbarics interfaces
If you do not wish to use the stricter methods you saw before, you can use the **..._barbaric** method.
There is **implement_barbaric** and **execute_barbaric** which does not use the GDInterface api but just take a method, signal or metadata as a name.
