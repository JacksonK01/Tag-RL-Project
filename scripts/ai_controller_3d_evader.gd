extends AIController3D

var move = Vector2.ZERO

@onready var tagger: CharacterBody3D = $"../../Tagger"
@onready var evader: CharacterBody3D = $".."

func get_obs() -> Dictionary:
	var ray_distances = evader.get_raycast_distances()
	var obs := [
		tagger.position.x,
		tagger.position.z,
		evader.position.x,
		evader.position.z,
		ray_distances["North"],
		ray_distances["South"],
		ray_distances["East"],
		ray_distances["West"],
		ray_distances["NorthEast"],
		ray_distances["NorthWest"],
		ray_distances["SouthEast"],
		ray_distances["SouthWest"]
	]
	return {"obs": obs}

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
