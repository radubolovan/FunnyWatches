extends Node2D

# modify this to experiment different time scales.
# go crazy: set this negative
const c_minutes_per_hour : int = 60

# It should be interesting to experiment modifying this one. Different planets, different rules. There are 24 hours per day only on Earth.
const c_hours_per_day : int = 24

# This is just a helper; should not be modified
const c_minutes_per_day : int = c_minutes_per_hour * c_hours_per_day

# The beginning of the simulation as in hours:minutes
# go crazy: set these negative
const c_starting_hours : int = 13
const c_starting_minutes : int = 0

# The ending of the simulation as in hours:minutes
# go crazy: set these negative
const c_ending_hours : int = 13
const c_ending_minutes : int = 0

const c_watches_delays : Array = [6, -12, 0]

# @TODO: in order to simulate more than 3 watches, these should become variables and initialize them in init_watches()
const c_starting_times : Array = [c_starting_hours * c_minutes_per_hour + c_starting_minutes, c_starting_hours * c_minutes_per_hour + c_starting_minutes, c_starting_hours * c_minutes_per_hour + c_starting_minutes]
const c_ending_times : Array = [c_ending_hours * c_minutes_per_hour + c_ending_minutes, c_ending_hours * c_minutes_per_hour + c_ending_minutes, c_ending_hours * c_minutes_per_hour + c_ending_minutes]
const c_minutes_in_hour : Array = [c_minutes_per_hour + c_watches_delays[0], c_minutes_per_hour + c_watches_delays[1], c_minutes_per_hour + c_watches_delays[2]]

var m_watches : Array = []
var m_watches_times : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void :
	var f = File.new()
	f.open("dump.txt", File.WRITE)
	f.store_string(start_simulation())
	f.close()

func init_watches():
	m_watches.clear()
	for idx in range(0, c_watches_delays.size()):
		m_watches.push_back(c_starting_times[idx])

	m_watches_times.clear()
	for idx in range(0, c_watches_delays.size()):
		m_watches_times.push_back(0)

func start_simulation() -> String :
	init_watches()

	var current_hour = 0

	var dump_str = ""
	var current_str = ""

	var end_of_simulation = false
	while(!end_of_simulation):
		# @TODO: increase the number of digits in the string if necessary. Can that number be predicted (as in how many days will pass 'till ... )? It should be!
		current_str = "after %4d hours => " % (current_hour + 1)

		for idx in range(0, c_watches_delays.size()):
			m_watches[idx] += c_minutes_in_hour[idx]
			m_watches_times[idx] = minutes_to_time(m_watches[idx])

			current_str += get_watch_string(m_watches_times[idx], idx)
			if(idx < c_watches_delays.size() - 1):
				current_str += " | "

		dump_str += current_str

		current_hour += 1

		# to check the simulation's end, each watch's hours and minutes have to be equal to the ending conditions
		for idx in range(0, m_watches_times.size()):
			# optimization: if at least one of the ending conditions is false, there is no need to continue the for loop
			if(m_watches_times[idx]['h'] != c_ending_hours || m_watches_times[idx]['m'] != c_ending_minutes):
				end_of_simulation = false
				break
			end_of_simulation = true

		if(!end_of_simulation):
			dump_str += "\n"

	dump_str += " --- BINGO !!!"

	return dump_str

# OBS: this function doesn't care about how many days are in a month or how many days are in a year
func minutes_to_time(minutes : int) -> Dictionary :
	var days = floor(float(minutes) / float(c_minutes_per_day))
	var hours = int(floor(float(minutes) / float(c_minutes_per_hour))) % c_hours_per_day
	var minutes_left = minutes % c_minutes_per_hour

	return {'d':days + 1, 'h':hours, 'm':minutes_left}

func get_watch_string(watch_dict : Dictionary, idx : int) -> String :
	 # @TODO: increase the number of digits in the string if necessary. Can that number be predicted? It should be!
	var day_format = "d:%3d" % watch_dict['d']

	var hour_format = "h:%02d" % watch_dict['h']
	var minute_format = "m:%02d" % watch_dict['m']
	return "watch_" + str(idx + 1) + ":(" + day_format + ", " + hour_format + ", " + minute_format + "}"
