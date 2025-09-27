extends MeshInstance3D

var pickable: Pickable = Pickable.new(pickable_implementation)
var picked_up: bool

func pickable_implementation(pickup: bool) -> void:
	if pickup:
		scale = Vector3.ONE * 0.7
	else: 
		scale = Vector3.ONE
