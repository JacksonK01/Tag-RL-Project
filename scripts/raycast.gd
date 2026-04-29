extends RayCast3D

@onready var evader: CharacterBody3D = $".."
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	evader.has_raycast_collided = is_colliding()
	
