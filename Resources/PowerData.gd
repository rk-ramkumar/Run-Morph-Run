class_name PowerData extends Resource

@export var name: String = ""  # Power name
@export var description: String = ""  # Short description of the power
@export var active_time: float = 60.0  # Duration in seconds
@export var cooldown: float = 30.0  # Cooldown before reuse
@export var cost: int = 0  # Cost to activate power
@export var type: String = "player"  # "player" or "actor"
@export var effect_strength: float = 1.0  # Strength of effect (can be used for scaling)
@export var icon: Texture2D
