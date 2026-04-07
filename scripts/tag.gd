extends Node3D

@onready var tagger: CharacterBody3D = $Tagger
@onready var evader: CharacterBody3D = $Evader

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var last_dist = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var current_dist = tagger.position.distance_to(evader.position)
	if current_dist < last_dist:
		tagger.add_reward(0.1)
		evader.add_reward(-0.1)
	else:
		tagger.add_reward(-0.1)
		evader.add_reward(0.1)
		
	last_dist = current_dist
	
	if current_dist <= 1.1:
		tagger.on_tagged()
		evader.on_tagged()
		print("Hello World")
