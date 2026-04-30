extends AIController3D

enum RewardMode { STUPID, DISTANCE, COMPLEX }
# Removed @export so it is no longer visible in this node's inspector
var current_reward_mode: RewardMode = RewardMode.COMPLEX

var move = Vector2.ZERO

@onready var tagger: CharacterBody3D = $".."
@onready var evader: CharacterBody3D = $"../../Evader"

func get_obs() -> Dictionary:
	var obs := [
		tagger.position.x,
		tagger.position.z,
		evader.position.x,
		evader.position.z,
		# Dummy values to pad the observation space
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0
	]
	return {"obs":obs}

func get_reward() -> float:	
	# 1. Grab accumulated sparse rewards (the +/- 15.0 given by the Arena)
	var step_reward = reward
	reward = 0.0 # Reset for the next physics frame
	
	match current_reward_mode:
		RewardMode.STUPID:
			pass # Only sparse tag rewards matter
		RewardMode.DISTANCE:
			var dist = tagger.global_position.distance_to(evader.global_position)
			step_reward -= dist * 0.01
		RewardMode.COMPLEX:
			var dist = tagger.global_position.distance_to(evader.global_position)
			step_reward -= dist * 0.01
			step_reward -= 0.01 # Time penalty
			
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
