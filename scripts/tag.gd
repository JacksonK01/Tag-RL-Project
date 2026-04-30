extends Node3D

# Create centralized dropdown menus in the Inspector
@export_enum("STUPID", "DISTANCE", "COMPLEX") var tagger_reward_mode: int = 2
@export_enum("STUPID", "DISTANCE", "COMPLEX") var evader_reward_mode: int = 2

@onready var tagger: CharacterBody3D = $Tagger
@onready var evader: CharacterBody3D = $Evader

var time_elapsed: float = 0.0
const MAX_TIME: float = 45.0

func _ready() -> void:
	# Push the selected modes down to the agent controllers as soon as the game loads
	tagger.get_node("AIController3DTagger").current_reward_mode = tagger_reward_mode
	evader.get_node("AIController3DEvader").current_reward_mode = evader_reward_mode

func _physics_process(delta: float) -> void:
	time_elapsed += delta
	
	var current_dist = tagger.global_position.distance_to(evader.global_position) 
	
	# Check for Tag
	if current_dist <= 1.1: 
		handle_tag()
		
	# Check for Timer
	elif time_elapsed >= MAX_TIME:
		handle_timeout()

func handle_tag():
	# Reward seeker, punish runner
	tagger.get_node("AIController3DTagger").reward += 15.0
	evader.get_node("AIController3DEvader").reward -= 15.0
	reset_arena()

func handle_timeout():
	# Punish seeker, reward runner
	tagger.get_node("AIController3DTagger").reward -= 15.0
	evader.get_node("AIController3DEvader").reward += 15.0
	reset_arena()

func reset_arena():
	time_elapsed = 0.0
	evader.reset_position()
	tagger.reset_position()
	
	# Inform Python the episode ended so it can restart the environment
	tagger.get_node("AIController3DTagger").reset()
	evader.get_node("AIController3DEvader").reset()
