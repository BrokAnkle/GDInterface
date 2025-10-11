extends MeshInstance3D

@onready var damage_mesh: MeshInstance3D = $DamageMesh

var idamageable: Damageable = Damageable.new(damage_implementation)

var health: int = 20


func _ready() -> void:
	(damage_mesh.mesh as TextMesh).text = str("Health = ", health)
	damage_mesh.get_node("outline").mesh = damage_mesh.mesh.create_outline(0.01)


func damage_implementation(damage_amount: int) -> int:
	health = max(health - damage_amount, 0)
	(damage_mesh.mesh as TextMesh).text = str("Health = ", health)
	damage_mesh.get_node("outline").mesh = damage_mesh.mesh.create_outline(0.01)
	if health == 0:
		(get_active_material(0) as StandardMaterial3D).albedo_color = Color.BLACK
		damage_mesh.mesh.text = "DEAD"
		damage_mesh.get_node("outline").mesh = damage_mesh.mesh.create_outline(0.01)
		damage_mesh.get_node("outline").get_active_material(0).albedo_color = Color.BLACK
	return health
