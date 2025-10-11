extends CharacterBody3D

@onready var raycast: RayCast3D = $Camera3D/RayCast3D
@onready var projectile_spawn_location: Marker3D = $Camera3D/ProjectileSpawnLocation
@onready var pickup_location: Marker3D = $Camera3D/PickupLocation
@onready var camera: Camera3D = $Camera3D
@onready var prompt_label: Label = $UI/Label

const PROJECTILE_SCENE: PackedScene = preload("uid://dqinb2r7fq2n8")
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var view_sensitivity: float = 0.1

var can_interact: bool = false
var interact_type: InterfaceType
var interact_object: Object

var picked_up_object: Node3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	raycast_process()

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if InputMap.has_action("move_left") and InputMap.has_action("move_right") and InputMap.has_action("move_forward") and InputMap.has_action("move_backward"):
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if move_and_slide():
		var collision: KinematicCollision3D = get_slide_collision(0)
		var jumpable = collision.get_collider().get_parent()
		if GDInterface.implements_barbaric(jumpable, "jumpable"):
			GDInterface.execute_barbaric_with_args(jumpable, "jumpable", [self])


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		event = event as InputEventKey
		if event.keycode == KEY_ESCAPE and !event.is_echo():
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if event.keycode == KEY_SPACE and !event.is_echo():
			# Handle jump.
			if is_on_floor():
				velocity.y = JUMP_VELOCITY
		if event.keycode == KEY_E and event.is_pressed() and !event.is_echo():
			try_interact()

	if event is InputEventMouseMotion:
		# If mouse visible, ignore mouse input
		if Input.mouse_mode == Input.MouseMode.MOUSE_MODE_VISIBLE: return
		## View rotation
		event = event as InputEventMouseMotion
		rotation_degrees.y -= event.relative.x * view_sensitivity
		camera.rotation_degrees.x -= event.relative.y * view_sensitivity

	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				shoot()


## Manage [member raycast]
func raycast_process() -> void:
	can_interact = false
	interact_object = null
	interact_type = null
	
	if raycast.is_colliding():
		var object = raycast.get_collider().get_parent()
		if GDInterface.implements(object, Interactable.get_interface_type()):
			prompt_label.show()
			prompt_label.text = "Press E to interact with " + object.name
			can_interact = true
			interact_type = Interactable.get_interface_type()
			interact_object = object
			
		if GDInterface.implements(object, Pickable.get_interface_type()):
			prompt_label.show()
			prompt_label.text = "Press E to pickup " + object.name
			can_interact = true
			interact_type = Pickable.get_interface_type()
			interact_object = object

	else: prompt_label.hide()


## Shoot a projectile that can damage [Damageable] objects
func shoot() -> void:
		var projectile: RigidBody3D = PROJECTILE_SCENE.instantiate()
		get_tree().root.add_child(projectile)
		projectile.global_position = projectile_spawn_location.global_position
		projectile.global_rotation = Vector3(camera.rotation.x, rotation.y, 0)


## If [member can_interact], interact with right interface ([Interactable] or pickup a [Pickable] ?)
func try_interact() -> void:
	if picked_up_object:
		drop_object()
		return
	if can_interact:
		if interact_type == Interactable.get_interface_type():
			GDInterface.execute(interact_object, Interactable.get_interface_type(), [Color(randf_range(0.0, 0.1), randf_range(0.0, 0.1), randf_range(0.0, 0.1)), "Player sent this message: Hi !"])
		elif interact_type == Pickable.get_interface_type():
			pickup(interact_object)


## Pick the given object up, if it implements the interface [Pickable]
func pickup(object: Object) -> void:
	GDInterface.execute(interact_object, Pickable.get_interface_type(), [true])
	object.reparent(pickup_location)
	picked_up_object = object


## Drop the picked_up_object
func drop_object() -> void:
	GDInterface.execute(picked_up_object, Pickable.get_interface_type(), [false])
	picked_up_object.reparent(get_tree().root)
	picked_up_object = null
