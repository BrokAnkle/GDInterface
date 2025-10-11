
# GDInterface

GDInterface is a Godot 4.x script plugin that adds Object Oriented Programming interface feature into GDScript.

## How to use

### Create an interface

Create an interface by creating a new script that inherits from Interface class.
Using the provided template for Interface scripts is highly recomanded to avoid any mistake. The template makes everything that is needed, it takes you script name and add the interface with this name. No need to do anything else.

>But if you want to write the script, you **MUST** give it a *class_name*, override the *_init()* function and override the *get_class()* function and the static function *get_interface_type*.
>
>In *_init()* simply do:
>```
>_init():
>   super(implementation)\
>   type = InterfaceType.new(self.get_class())\
>   types[self.get_class()] = type\
>```
>In *get_class()* just return the string of your class name
>
>In *get_interface_type*, just return *`Interface.types[self.get_class()]`*

### Implement an interface

In the script you wish to implement an interface, create the function that will be executed by the interface.
Then create a variable of the type of your interface and give it the function as the argument in its constructor.
You can use arguments and return in your implementation.

For example, if you wish to have multiple interactable objects that do differents actions when interacted, create an Interactable interface.
Let's take a door, a light switch and a pickable object. In the door script, add an Interactable variable and initialize it with its implementation, which should rotate the door. In the light switch do the same but change the implementation to toggle the light. At last, in the pickable object, make the implementation sticking to the player picking slot.


### Execute an interface

Where you wish to execute an interface, use the **GDInterface** singleton.

You can check if the object you wish to call the interface from, actually implements it by using *GDInterface.implement* function.
It take the external object and the *InterfaceType* as arguments. It returns true if the the interface exists in the given object.

You execute the interface by using *GDInterface.execute* function.
Give it the object you wish to execute the interface from, and the *InterfaceType*. You can add the arguments to pass to the interface as an *Array*.

Let's go back in the example from the previous section: In the player scene, add a raycast, and when the raycast hit something, call `GDInterface.execute(raycast.get_collider(), Interactable.get_interface_type())`.
With this interaction implementation, there is no need to check the type of the object and call the right method. We don't need to know anything about this object *(aside that it's not null)*.
```
if raycast.get_collider() is Door:
	raycast.get_collider().open_door()
elif raycast.get_collider() is LightSwitch:
	raycast.get_collider().toggle_light()
elif raycast.get_collider() is PickableObject:
	raycast.get_collider().pickup()
```
**Note: it is not mandatory to check if the interface is implemented, as *execute* will check again, and if the interface isn't implemented, or the passed arguments are of the wrong order or type, nothing will happen*.*


#### Barbarics interfaces
If you do not wish to use the stricter methods you saw before, you can use the **..._barbaric** method.
There is **implement_barbaric** and **execute_barbaric_with_args** and **execute_barbaric_no_args** which does not use the GDInterface api but just take a method, signal or metadata as a *String* and call the function/signal if found.
