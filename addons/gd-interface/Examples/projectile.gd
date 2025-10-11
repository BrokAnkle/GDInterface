extends RigidBody3D

const SPEED = 20

var velocity: Vector3
var damage: int = 4

func _physics_process(delta: float) -> void:
	velocity = -global_basis.z * SPEED
	var collision = move_and_collide(velocity*delta)
	if collision:
		var object: Object = collision.get_collider()
		if !GDInterface.implements(object, Damageable.get_interface_type()):
			object = object.get_parent()
			if !GDInterface.implements(object, Damageable.get_interface_type()):
				object = null
		if object:
			var remaining_health: int = GDInterface.execute(object, Damageable.get_interface_type(), [damage])
			print_rich(str("[color=yellow]Projectile knows that ", object.name, " has ", remaining_health, " health"))
			
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
