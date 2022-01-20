class_name TentacleRenderer extends ColorRect


# Private variables

var __image: Image = Image.new()
var __texture: ImageTexture = ImageTexture.new()

var __vertices: Array = [Vector2(640.0, 360.0), Vector2.ZERO]


# Lifecycle methods

func _process(delta: float) -> void:
	var tentacles_raw: Array = get_tree().get_nodes_in_group("tentacle")
	var tentacles: Array = []

	for tentacle in tentacles_raw:
		if tentacle is Path2D:
			tentacles.append(
				TentacleData.new(
					tentacle.curve.get_baked_points(),
					20.0,
					20.0,
					1
				)
			)
		elif tentacle is Rope:
			tentacles.append(
				TentacleData.new(
					tentacle.rope_points,
					30.0,
					10.0,
					4
				)
			)

	set_points(tentacles)


# Public methods

func set_points(tentacles: Array) -> void:
	var row_count: int = tentacles.size()
	var col_count: int = 0

	for tentacle in tentacles:
		col_count = max(col_count, tentacle.size())

	__image.create(col_count + 1, row_count, false, Image.FORMAT_RGBAH)
	__image.lock()

	for r in row_count:
		var tentacle: TentacleData = tentacles[r]

		__image.set_pixel(0, r, tentacle.metadata())

		var packed_data: PoolColorArray = tentacle.packed_data()
		for c in tentacle.size():
			__image.set_pixel(c + 1, r, packed_data[c])

	__image.unlock()

	__texture.create_from_image(__image)

	material.set_shader_param("tentacles", __texture)
	material.set_shader_param("tentacle_count", row_count)
