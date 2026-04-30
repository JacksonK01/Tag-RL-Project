extends AIController3D

enum EvaderRewardMode {STUPID, DISTANCE, COMPLEX}
# Removed @export
var current_reward_mode: EvaderRewardMode = EvaderRewardMode.COMPLEX

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
	# Grab accumulated sparse rewards (the +/- 10.0 given by the Arena)
	var step_reward = reward
	reward = 0.0 
	var dist = tagger.global_position.distance_to(evader.global_position)
	match current_reward_mode:
		
		EvaderRewardMode.STUPID:
			pass # Only relies on the timeout victory
		EvaderRewardMode.DISTANCE:
			step_reward += dist * 0.01
		EvaderRewardMode.COMPLEX:
			if evader.get("has_raycast_collided"):
				step_reward -= 0.1 # Wall collision penalty
			step_reward += dist * 0.01
			step_reward += 0.01 # Time bonus

	
	return step_reward
	
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
