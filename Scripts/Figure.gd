extends Node
class_name Figure

var top_border
var bottom_border
var left_border
var right_border

const figures_description = {
	"i": [Color("#00ffff"), Vector2(-Block.block_size, 0), Vector2(0, 0), Vector2(Block.block_size, 0), Vector2(Block.block_size * 2, 0)],
	"o": [Color("#ffff00"), Vector2(0, -Block.block_size), Vector2(Block.block_size, -Block.block_size), Vector2(0, 0), Vector2(Block.block_size, 0)],
	"t": [Color("#ff00ff"), Vector2(0, -Block.block_size), Vector2(-Block.block_size, 0), Vector2(0, 0), Vector2(Block.block_size, 0)],
	"j": [Color("#ff7f00"), Vector2(-Block.block_size, -Block.block_size), Vector2(-Block.block_size, 0), Vector2(0, 0), Vector2(Block.block_size, 0)],
	"l": [Color("#0000ff"), Vector2(Block.block_size, -Block.block_size), Vector2(-Block.block_size, 0), Vector2(0, 0), Vector2(Block.block_size, 0)],
	"s": [Color("#00ff00"), Vector2(0, -Block.block_size), Vector2(Block.block_size, -Block.block_size), Vector2(-Block.block_size, 0), Vector2(0, 0)],
	"z": [ Color("#ff0000"), Vector2(-Block.block_size, -Block.block_size), Vector2(0, -Block.block_size), Vector2(0, 0), Vector2(Block.block_size, 0)],
}

var figure_name

var coordinates
var blocks_coordinates
var blocks

func _init(set_figure_name, initial_coordinates, set_top_border, set_bottom_border, set_left_border, set_right_border):
	blocks = []

	top_border = set_top_border
	bottom_border = set_bottom_border
	left_border = set_left_border
	right_border = set_right_border

	coordinates = initial_coordinates

	figure_name = set_figure_name
	var figure_description = figures_description[figure_name];
	blocks_coordinates = figure_description.slice(1)
	var color = figure_description[0]

	for i in len(figure_description) - 1:
		var block = Block.Block_scene.instantiate()
		var block_sprite = block.get_node("Block")

		Block.change_color(block_sprite, color, color)

		blocks.append(block)

	update_blocks_coordinates()

#func change into a ghost

#func change to next figure

func update_blocks_coordinates():
	for i in len(blocks):
		blocks[i].position = blocks_coordinates[i] + coordinates

#Сheck lines functions

func check_line_fill(locked_blocks, field_width):
	var last_fallen_blocks_coordinates_y = []
	var blocks_indexes_in_tested_line
	
	var blocks_indexes_in_filled_lines =[]
	var filled_lines_coordinates_y = []

	var locked_blocks_coordinates = []

	for block in locked_blocks:
		locked_blocks_coordinates.append(block.position)

	for block in blocks:
		if !(block.position.y in last_fallen_blocks_coordinates_y):
			last_fallen_blocks_coordinates_y.append(block.position.y)

	for block_coordinate_y in last_fallen_blocks_coordinates_y:
		blocks_indexes_in_tested_line = []

		for field_block in field_width:
			var block_index_in_tested_line = locked_blocks_coordinates.find(Vector2(left_border + field_block * Block.block_size, block_coordinate_y))
			if block_index_in_tested_line != -1:
				blocks_indexes_in_tested_line.append(block_index_in_tested_line)

		if len(blocks_indexes_in_tested_line) == field_width:
			blocks_indexes_in_filled_lines.append_array(blocks_indexes_in_tested_line)
			filled_lines_coordinates_y.append(block_coordinate_y)

	var number_filled_lines = len(filled_lines_coordinates_y)

	if number_filled_lines != 0:
		locked_blocks = remove_filled_lines(locked_blocks, blocks_indexes_in_filled_lines)
		move_locked_blocks_down(locked_blocks, filled_lines_coordinates_y)

		#update_score(number_filled_lines)
		#change_speed(number_filled_lines)

	return locked_blocks

func remove_filled_lines(locked_blocks, blocks_indexes_in_filled_lines):
	blocks_indexes_in_filled_lines.sort()
	blocks_indexes_in_filled_lines.reverse()

	for block_index in blocks_indexes_in_filled_lines:
		locked_blocks[block_index].queue_free()
		locked_blocks.remove_at(block_index)

	return locked_blocks

func move_locked_blocks_down(locked_blocks, filled_lines_coordinates_y):
	filled_lines_coordinates_y.sort()

	for filled_line_coordinate_y in filled_lines_coordinates_y:
		for i in len(locked_blocks):
			if locked_blocks[i].position.y <= filled_line_coordinate_y:
				locked_blocks[i].position.y += Block.block_size



#Move functions

func check_move_down(locked_blocks):
	if blocks == []: #or paused
		return null

	else:
		var locked_blocks_coordinates = []

		for block in locked_blocks:
			locked_blocks_coordinates.append(block.position)

		var next_block_coordinates

		for i in len(blocks):
			next_block_coordinates = blocks_coordinates[i] + coordinates
			next_block_coordinates.y += Block.block_size

			if next_block_coordinates.y > bottom_border or next_block_coordinates in locked_blocks_coordinates:
				return false

		move_down()
		return true

func move_down():
	coordinates.y += Block.block_size
	update_blocks_coordinates()

func check_move_rotation(locked_blocks, direction):
	if blocks == [] or figure_name == "o": #or paused
		return null

	else:
		var locked_blocks_coordinates = []

		for block in locked_blocks:
			locked_blocks_coordinates.append(block.position)

		var next_block_coordinates

		for block_coordinates in blocks_coordinates:
			next_block_coordinates = Vector2(-block_coordinates.y * direction, block_coordinates.x * direction) + coordinates

			if next_block_coordinates.y > bottom_border or next_block_coordinates.x > right_border or next_block_coordinates.x < left_border or next_block_coordinates in locked_blocks_coordinates:
				return check_move_super_rotation(locked_blocks_coordinates, direction)

		rotation(direction)
		return true

func check_move_super_rotation(locked_blocks_coordinates, direction):
	var flag = true
	
	var next_block_coordinates

	var next_coordinates = coordinates
	next_coordinates.x += Block.block_size

	for block_coordinates in blocks_coordinates:
		next_block_coordinates = Vector2(-block_coordinates.y * direction, block_coordinates.x * direction) + next_coordinates
		if next_block_coordinates.y > bottom_border or next_block_coordinates.x > right_border or next_block_coordinates.x < left_border or next_block_coordinates in locked_blocks_coordinates:
			flag = false
			break

	if flag:
		coordinates = next_coordinates
		rotation(direction)
		return true
	flag = true

	next_coordinates = coordinates
	next_coordinates.x -= Block.block_size

	for block_coordinates_2 in blocks_coordinates:
		next_block_coordinates = Vector2(-block_coordinates_2.y * direction, block_coordinates_2.x * direction) + next_coordinates
		if next_block_coordinates.y > bottom_border or next_block_coordinates.x > right_border or next_block_coordinates.x < left_border or next_block_coordinates in locked_blocks_coordinates:
			flag = false
			break

	if flag:
		coordinates = next_coordinates
		rotation(direction)
		return true
	flag = true

	if figure_name == "i":

		next_coordinates = coordinates
		next_coordinates.x += Block.block_size * 2

		for block_coordinates_2 in blocks_coordinates:
			next_block_coordinates = Vector2(-block_coordinates_2.y * direction, block_coordinates_2.x * direction) + next_coordinates
			if next_block_coordinates.y > bottom_border or next_block_coordinates.x > right_border or next_block_coordinates.x < left_border or next_block_coordinates in locked_blocks_coordinates:
				flag = false
				break

		if flag:
			coordinates = next_coordinates
			rotation(direction)
			return true
		flag = true
		
		next_coordinates = coordinates
		next_coordinates.x -= Block.block_size * 2

		for block_coordinates_2 in blocks_coordinates:
			next_block_coordinates = Vector2(-block_coordinates_2.y * direction, block_coordinates_2.x * direction) + next_coordinates
			if next_block_coordinates.y > bottom_border or next_block_coordinates.x > right_border or next_block_coordinates.x < left_border or next_block_coordinates in locked_blocks_coordinates:
				flag = false
				break

		if flag:
			coordinates = next_coordinates
			rotation(direction)
			return true

	return false

func rotation(direction):
	var next_block_coordinates

	for i in len(blocks_coordinates):
		next_block_coordinates = blocks_coordinates[i].x * direction
		blocks_coordinates[i].x = -blocks_coordinates[i].y * direction
		blocks_coordinates[i].y = next_block_coordinates

	update_blocks_coordinates()

func check_move_right(locked_blocks):
	if blocks == []: #or paused
		return null

	else:
		var locked_blocks_coordinates = []

		for block in locked_blocks:
			locked_blocks_coordinates.append(block.position)

		var next_block_coordinates

		for i in len(blocks):
			next_block_coordinates = blocks_coordinates[i] + coordinates
			next_block_coordinates.x += Block.block_size

			if next_block_coordinates.x > right_border or next_block_coordinates in locked_blocks_coordinates:
				return false

		move_right()
		return true

func move_right():
	coordinates.x += Block.block_size
	update_blocks_coordinates()

func check_move_left(locked_blocks):
	if blocks == []: #or paused
		return null

	else:
		var locked_blocks_coordinates = []

		for block in locked_blocks:
			locked_blocks_coordinates.append(block.position)

		var next_block_coordinates

		for i in len(blocks):
			next_block_coordinates = blocks_coordinates[i] + coordinates
			next_block_coordinates.x -= Block.block_size

			if next_block_coordinates.x < left_border or next_block_coordinates in locked_blocks_coordinates:
				return false

		move_left()
		return true

func move_left():
	coordinates.x -= Block.block_size
	update_blocks_coordinates()





