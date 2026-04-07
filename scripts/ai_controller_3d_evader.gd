extends AIController3D

var move = Vector2.ZERO

@onready var tagger: CharacterBody3D = $"../../Tagger"
@onready var evader: CharacterBody3D = $".."

func get_obs() -> Dictionary:
	var obs := [
		tagger.position.x,
		tagger.position.z,
		evader.position.x,
		evader.position.z
	]
	return {"obs":obs}

func get_reward() -> float:	
	return reward
	
func get_action_space() -> Dictionary:
	return {
		"move" : {
			"size": 2,
			"action_type": "continuous"
		}
	}
	
func set_action(action) -> void:	
	move.x = action["move"][0]
	move.y = action["move"][1]
