extends Node3D

# Create centralized dropdown menus in the Inspector
@export_enum("STUPID", "DISTANCE", "COMPLEX") var tagger_reward_mode: int = 2
@export_enum("STUPID", "DISTANCE", "COMPLEX") var evader_reward_mode: int = 2

@onready var tagger: CharacterBody3D = $Tagger
@onready var evader: CharacterBody3D = $Evader

const WIN_REWARD = 15.0

var time_elapsed: float = 0.0
const MAX_TIME: float = 45.0

# Data Collection Variables
var games_played: int = 0
var tagger_wins: int = 0
var evader_wins: int = 0

var total_cumulative_distance: float = 0.0
var total_frames: int = 0
var total_time_to_tag: float = 0.0

var current_dist = 0
var previous_dist = 0

var round_log: Array = []

func _ready() -> void:
	# Push the selected modes down to the agent controllers as soon as the game loads
	tagger.get_node("AIController3DTagger").current_reward_mode = tagger_reward_mode
	evader.get_node("AIController3DEvader").current_reward_mode = evader_reward_mode
	print("Reward mode: " + str(tagger_reward_mode))
	print("Reward mode: " + str(evader_reward_mode))
	get_tree().set_auto_accept_quit(false)

func _physics_process(delta: float) -> void:
	time_elapsed += delta
	current_dist = tagger.global_position.distance_to(evader.global_position) 
	# Track data continuously for the average distance metric
	total_cumulative_distance += current_dist
	total_frames += 1
	
	if tagger_reward_mode == 0:
		handle_stupid_ai_tagger()
	elif tagger_reward_mode == 1:
		handle_distance_ai_tagger()
	elif tagger_reward_mode == 2:
		handle_complex_ai_tagger()
		
	if evader_reward_mode == 0:
		handle_stupid_ai_evader()
	elif evader_reward_mode == 1:
		handle_distance_ai_evader()
	elif evader_reward_mode == 2:
		handle_complex_ai_evader()
		
	# Check for Tag
	if current_dist <= 1.1: 
		handle_tag()
		
	# Check for Timer
	elif time_elapsed >= MAX_TIME:
		handle_timeout()
		
	previous_dist = current_dist
		
func handle_stupid_ai_tagger():
	pass
		
func handle_distance_ai_tagger():
	if current_dist < previous_dist:
		tagger.add_reward(0.1)
	else:
		tagger.add_reward(-0.1)
	
func handle_complex_ai_tagger():
	#Rewarding getting closer
	if current_dist < previous_dist:
		tagger.add_reward(0.1)
	else:
		tagger.add_reward(-0.05)

	#Rewards being close
	if current_dist < 5.0:
		var closeness = (5.0 - current_dist) / 5.0
		tagger.add_reward(0.2 * closeness)

	#Encourages the AI not to stand still
	if tagger.velocity.length() < 0.5:
		tagger.add_reward(-0.05)

	#Rewards predicting movement
	var predicted_evader_pos = evader.global_position + evader.velocity * 0.5
	var dist_to_predicted = tagger.global_position.distance_to(predicted_evader_pos)
	if dist_to_predicted < current_dist:
		tagger.add_reward(0.15)

func handle_stupid_ai_evader():
	pass
		
func handle_distance_ai_evader():
	if current_dist > previous_dist:
		evader.add_reward(0.1)
	else:
		evader.add_reward(-0.1)
	
func handle_complex_ai_evader():
	# Rewards for getting away from tagger
	if current_dist > previous_dist:
		evader.add_reward(0.1)
	else:
		evader.add_reward(-0.05)
	
	# Negative reward for when touching wall
	var amount = evader.get_amount_raycast_collided()
	if amount > 0:
		var corner_penalty = -0.05 * pow(amount, 2)
		evader.add_reward(corner_penalty)
	evader.raycasts_colliding.clear()
	
	# Negative reward for being really close to tagger
	if current_dist < 3.0:
		var danger = (3.0 - current_dist) / 3.0
		evader.add_reward(-0.3 * danger)
	
	# Reward for living
	evader.add_reward(0.01)


func handle_tag():
	# Update Metrics for Tagger Win
	tagger_wins += 1
	games_played += 1
	total_time_to_tag += time_elapsed
	
	# Reward seeker, punish runner
	tagger.add_reward(WIN_REWARD)
	evader.add_reward(-WIN_REWARD)
	
	log_statistics("tagger")
	
	if games_played >= 2000:
		save_statistics_to_csv()
		get_tree().quit()
		
	reset_arena()

func handle_timeout():
	# Update Metrics for Evader Win
	evader_wins += 1
	games_played += 1
	
	# Punish seeker, reward runner
	tagger.add_reward(-WIN_REWARD)
	evader.add_reward(WIN_REWARD)
	
	log_statistics("evader")
	
	if games_played >= 2000:
		save_statistics_to_csv()
		get_tree().quit()
		
	reset_arena()

func reset_arena():
	time_elapsed = 0.0
	evader.reset_position()
	tagger.reset_position()
	
	# Inform Python the episode ended so it can restart the environment
	tagger.get_node("AIController3DTagger").reset()
	evader.get_node("AIController3DEvader").reset()

# Data Output Function
func log_statistics(winner):
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
		
	round_log.append({
		"round": games_played,
		"winner": winner,  
		"time": time_elapsed,
		"tagger_wr": (float(tagger_wins) / float(games_played)) * 100.0,
		"evader_wr": (float(evader_wins) / float(games_played)) * 100.0,
		"avg_dist": total_cumulative_distance / float(total_frames),
		"avg_tag_time": total_time_to_tag / float(tagger_wins) if tagger_wins > 0 else 0.0
	})
		
func did_collide() -> bool:
	return current_dist <= 1.1
	
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_statistics_to_csv()
		get_tree().quit()
		
func save_statistics_to_csv() -> void:
	var mode_names = ["stupid", "distance", "complex"]
	var tagger_name = mode_names[tagger_reward_mode]
	var evader_name = mode_names[evader_reward_mode]
	var filename = "results_tagger-%s_evader-%s.csv" % [tagger_name, evader_name]
	var file = FileAccess.open("user://" + filename, FileAccess.WRITE)
	if file == null:
		print("ERROR: Could not save CSV")
		return
		
	# Header row
	file.store_csv_line(["Round", "Winner", "Time_Elapsed", "Tagger_Win_Rate", "Evader_Win_Rate", "Avg_Distance", "Avg_Time_To_Tag"])
	
# One row per round — you'll need to track per-round data (see below)
	for i in round_log.size():
		var r = round_log[i]
		file.store_csv_line([r.round, r.winner, r.time, r.tagger_wr, r.evader_wr, r.avg_dist, r.avg_tag_time])
	file.close()
	print("Saved to: " + OS.get_user_data_dir() + "/" + filename)
