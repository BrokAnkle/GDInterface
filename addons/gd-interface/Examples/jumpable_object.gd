extends MeshInstance3D

const JUMP_FORCE: float = 300.0
var character_to_jump: CharacterBody3D
var body_to_jump: RigidBody3D

func jumpable(object: Node3D) -> void:
	(get_active_material(0) as StandardMaterial3D).albedo_color = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	if object is CharacterBody3D:
		character_to_jump = object
	if object is RigidBody3D:
		body_to_jump = object

func _physics_process(delta: float) -> void:
	if character_to_jump:
		character_to_jump.velocity.y += JUMP_FORCE * delta
		character_to_jump = null
	if body_to_jump:
		body_to_jump.linear_velocity.y = JUMP_FORCE * delta
		body_to_jump = null
