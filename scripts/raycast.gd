extends RayCast3D

@onready var evader: CharacterBody3D = $".."
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	evader.raycasts_colliding.append(is_colliding())
	
