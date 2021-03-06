extends Node


# Private constants

const __SIZE: Vector2 = Vector2(1280.0, 720.0)


# Private variables

var __tween: Tween = Tween.new()

onready var __output: ColorRect = $output


# Lifecycle methods

func _ready() -> void:
	add_child(__tween)

	var bubbles: Array = []

	for i in 100:
		bubbles.append(Color(randf() * __SIZE.x, randf() * __SIZE.y, randf() * 100.0 + 25.0, randf() * 0.3))

	var background_bubbles: Array = []

	for x in 14:
		for y in 8:
			background_bubbles.append(Color(100.0 * x, 100.0 * y, 50.0, randf() * 0.4 + 0.2))
			background_bubbles.append(Color(50.0 + 100.0 * x, 50.0 + 100.0 * y, 50.0, randf() * 0.4 + 0.2))

	background_bubbles.shuffle()

	bubbles.append_array(background_bubbles)

	var image: Image = Image.new()

	image.create(bubbles.size(), 1, false, Image.FORMAT_RGBAH)
	image.lock()

	for index in bubbles.size():
		image.set_pixel(index, 0, bubbles[index] / __SIZE.x)

	image.unlock()

	var texture: ImageTexture = ImageTexture.new()
	texture.create_from_image(image)

	__output.material.set_shader_param("bubbles", texture)
	__output.material.set_shader_param("bubble_count", bubbles.size())
	__output.material.set_shader_param("bubble_time", 1.0)


# Public methods

func fade_in() -> void:
	__tween.interpolate_method(
		self,
		"__set_time",
		1.0,
		0.0,
		0.9,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	__tween.start()


	yield(__tween, "tween_completed")


func fade_out() -> void:
	# BUBBLE SOUNDS!
	Event.emit_signal("emit_audio", {"type": "effect", "name": "transition"})

	__tween.interpolate_method(
		self,
		"__set_time",
		0.0,
		1.0,
		0.9,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT
	)
	__tween.start()

	yield(__tween, "tween_completed")

# Private methods

func __set_time(time: float) -> void:
	__output.material.set_shader_param("bubble_time", time)
