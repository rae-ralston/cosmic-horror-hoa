extends Control

@onready var time_label: Label = $Label

# Colors for different phases
const COLOR_NORMAL = Color.WHITE
const COLOR_WARNING = Color.ORANGE
const COLOR_DANGER = Color.RED

var time_remaining: float = 0.0
var current_phase: PhaseManager.Phase = PhaseManager.Phase.NORMAL

func _ready():
	# Subscribe to PhaseManager signals
	PhaseManager.phase_changed.connect(_on_phase_changed)
	# Initialize with current phase
	current_phase = PhaseManager.get_current_phase()

func _process(_delta):
	# Get current time remaining from PhaseManager
	time_remaining = PhaseManager.get_time_remaining()
	_update_display()

func _update_display():
	# Format time as MM:SS or SS
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60

	if minutes > 0:
		time_label.text = "%02d:%02d" % [minutes, seconds]
	else:
		time_label.text = "%02d" % seconds

	# Update color based on phase
	match current_phase:
		PhaseManager.Phase.NORMAL:
			time_label.modulate = COLOR_NORMAL
		PhaseManager.Phase.WARNING:
			time_label.modulate = COLOR_WARNING
		PhaseManager.Phase.DANGER:
			time_label.modulate = COLOR_DANGER

func _on_phase_changed(phase: PhaseManager.Phase):
	current_phase = phase
