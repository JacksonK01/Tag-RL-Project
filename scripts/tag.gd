extends Node3D

# Create centralized dropdown menus in the Inspector
@export_enum("STUPID", "DISTANCE", "COMPLEX") var tagger_reward_mode: int = 2
@export_enum("STUPID", "DISTANCE", "COMPLEX") var evader_reward_mode: int = 2

@onready var tagger: CharacterBody3D = $Tagger
@onready var evader: CharacterBody3D = $Evader

var time_elapsed: float = 0.0
const MAX_TIME: float = 45.0

# Data Collection Variables
var games_played: int = 0
var tagger_wins: int = 0
var evader_wins: int = 0

var total_cumulative_distance: float = 0.0
var total_frames: int = 0
var total_time_to_tag: float = 0.0

func _ready() -> void:
	# Push the selected modes down to the agent controllers as soon as the game loads
	tagger.get_node("AIController3DTagger").current_reward_mode = tagger_reward_mode
	evader.get_node("AIController3DEvader").current_reward_mode = evader_reward_mode

func _physics_process(delta: float) -> void:
	time_elapsed += delta
	
	var current_dist = tagger.global_position.distance_to(evader.global_position) 
	
	# Track data continuously for the average distance metric
	total_cumulative_distance += current_dist
	total_frames += 1
	
	# Check for Tag
	if current_dist <= 1.1: 
		handle_tag()
		
	# Check for Timer
	elif time_elapsed >= MAX_TIME:
		handle_timeout()
		
	if evader.has_method("has_any_raycast_collided") and evader.has_any_raycast_collided():
		pass
	if "raycasts_colliding" in evader:
		evader.raycasts_colliding.clear()

func handle_tag():
	# Update Metrics for Tagger Win
	tagger_wins += 1
	games_played += 1
	total_time_to_tag += time_elapsed
	
	# Reward seeker, punish runner
	tagger.get_node("AIController3DTagger").reward += 15.0
	evader.get_node("AIController3DEvader").reward -= 15.0
	
	log_statistics()
	reset_arena()

func handle_timeout():
	# Update Metrics for Evader Win
	evader_wins += 1
	games_played += 1
	
	# Punish seeker, reward runner
	tagger.get_node("AIController3DTagger").reward -= 15.0
	evader.get_node("AIController3DEvader").reward += 15.0
	
	log_statistics()
	reset_arena()

func reset_arena():
	time_elapsed = 0.0
	evader.reset_position()
	tagger.reset_position()
	
	# Inform Python the episode ended so it can restart the environment
	tagger.get_node("AIController3DTagger").reset()
	evader.get_node("AIController3DEvader").reset()

# Data Output Function
func log_statistics():
	var tagger_win_rate = (float(tagger_wins) / float(games_played)) * 100.0
	var evader_win_rate = (float(evader_wins) / float(games_played)) * 100.0
	var avg_dist = total_cumulative_distance / float(total_frames)
	
	var avg_tag_time = 0.0
	if tagger_wins > 0:
		avg_tag_time = total_time_to_tag / float(tagger_wins)
		
	# Print statements for data
	print("\n--- ROUND ", games_played, " COMPLETE ---")
	print("Tagger Win Rate: ", str(tagger_win_rate).pad_decimals(2), "%")
	print("Evader Win Rate: ", str(evader_win_rate).pad_decimals(2), "%")
	print("Average Distance: ", str(avg_dist).pad_decimals(2), " meters")
	if tagger_wins > 0:
		print("Average Time to Tag: ", str(avg_tag_time).pad_decimals(2), " seconds")
