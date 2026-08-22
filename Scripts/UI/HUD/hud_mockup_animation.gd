extends TextureRect

@export var hud_mockup: TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud_mockup.visible = false
	
	if GameManager.expedition_started:
		hud_mockup.position.y = -2000
		hud_mockup.visible = true
		self.texture = load("res://Assets/UI/HUD_mockup_clean_1.png")
		
		#lower visor
		var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(self, "position:y", -45, .7)
				
		#open view
		await get_tree().create_timer(.9).timeout
		self.texture = load("res://Assets/UI/HUD_mockup_clean_2.png")

		#flicker
		await get_tree().create_timer(.05).timeout
		self.texture = load("res://Assets/UI/HUD_mockup_clean_1.png")
		await get_tree().create_timer(.1).timeout
		self.texture = load("res://Assets/UI/HUD_mockup_clean_2.png")
		
		#activate hud
		#await get_tree().create_timer(.4).timeout
		#self.texture = load("res://Assets/UI/HUD_mockup_clean_3.png")
		##flicker
		#await get_tree().create_timer(.05).timeout
		#self.texture = load("res://Assets/UI/HUD_mockup_clean_2.png")
		#await get_tree().create_timer(.1).timeout
		#self.texture = load("res://Assets/UI/HUD_mockup_clean_3.png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
	#pass
