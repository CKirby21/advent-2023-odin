package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"

run_day10_part2 :: proc() {

	filepath := "10_input.txt"
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	area: [dynamic][dynamic]Tile
	defer delete(area)

	Direction :: enum {
		None,
		North,
		NorthNortheast,
		Northeast,
		EastNortheast,
		East,
		EastSoutheast,
		Southeast,
		SouthSoutheast,
		South,
		SouthSouthwest,
		Southwest,
		WestSouthwest,
		West,
		WestNorthwest,
		Northwest,
		NorthNorthwest,
	}

	Position :: struct {
		x: int,
		y: int,
		direction: Direction
	}

	Type :: enum {
		Unknown,
		Loop,
		Inside,
		Outside
	}

	Tile :: struct {
		pipe: rune,
		type: Type,
	}

	Bounds :: struct {
		min: [2]int,
		max: [2]int
	}

	out_of_bounds :: proc(area: [dynamic][dynamic]Tile, position: Position) -> bool {

		if position.x < 0 || position.x >= len(area) {
			return true
		}
		if position.y < 0 || position.y >= len(area[position.x]) {
			return true
		}
		return false
	}

	opposite_direction :: proc(direction: Direction) -> (opposite: Direction) {
		switch direction {
		case .None:
			opposite = .None
		case .North:
			opposite = .South
		case .NorthNortheast:
			opposite = .SouthSouthwest
		case .Northeast:
			opposite = .Southwest
		case .EastNortheast:
			opposite = .WestSouthwest
		case .East:
			opposite = .West
		case .EastSoutheast:
			opposite = .WestNorthwest
		case .Southeast:
			opposite = .Northwest
		case .SouthSoutheast:
			opposite = .NorthNorthwest
		case .South:
			opposite = .North
		case .SouthSouthwest:
			opposite = .NorthNortheast
		case .Southwest:
			opposite = .Northeast
		case .WestSouthwest:
			opposite = .EastNortheast
		case .West:
			opposite = .East
		case .WestNorthwest:
			opposite = .EastSoutheast
		case .Northwest:
			opposite = .Southeast
		case .NorthNorthwest:
			opposite = .SouthSoutheast
		}
		return opposite

	}

	valid_pipe :: proc(area: [dynamic][dynamic]Tile, current: Position, direction: Direction) -> (Position, bool) {

		next := current
		next.direction = direction

		#partial switch direction {
		case .North:
			next.x -= 1
		case .East:
			next.y += 1
		case .South:
			next.x += 1
		case .West:
			next.y -= 1
		case:
			panic("Direction should never be here")
		}

		if out_of_bounds(area, next) {
			return next, false
		}

		pipe := area[next.x][next.y].pipe
		direction_pipes := map[Direction][]rune {
			.North = {'7', '|', 'F', 'S'},
			.East = {'J', '-', '7', 'S'},
			.South = {'J', '|', 'L', 'S'},
			.West = {'L', '-', 'F', 'S'},
		}
		defer delete(direction_pipes)

		if slice.contains(direction_pipes[direction], pipe) {
			return next, true
		}

		return next, false
	}

	get_directions :: proc(pipe: rune) -> []Direction {

		pipe_directions := map[rune][]Direction {
			'|' = {.North, .South},
			'-' = {.West, .East},
			'L' = {.North, .East},
			'J' = {.North, .West},
			'7' = {.West, .South},
			'F' = {.East, .South},
			'S' = {.North, .East, .South, .West},
		}
		defer delete(pipe_directions)
		directions := slice.clone(pipe_directions[pipe])
		return directions
	}

	step :: proc(area: [dynamic][dynamic]Tile, position: ^Position) {

		area[position.x][position.y].type = .Loop

		explored_direction := opposite_direction(position.direction)
		directions := get_directions(area[position.x][position.y].pipe)

		for direction in directions {

			// We don't want to go back the way we came
			if direction == explored_direction {
				continue
			}

			new_position, ok := valid_pipe(area, position^, direction)
			if ok {
				position^ = new_position
				break
			}
		}
	}

	convert :: proc(area: ^[dynamic][dynamic]Tile, position: Position, type: Type) {

		neighbor_positions := [?]Position{
			Position{ position.x - 1, position.y,     .None },
			Position{ position.x - 1, position.y + 1, .None },
			Position{ position.x,     position.y + 1, .None },
			Position{ position.x + 1, position.y + 1, .None },
			Position{ position.x + 1, position.y,     .None },
			Position{ position.x + 1, position.y - 1, .None },
			Position{ position.x,     position.y - 1, .None },
			Position{ position.x - 1, position.y - 1, .None }
		}

		for neighbor_position in neighbor_positions {
			if area[neighbor_position.x][neighbor_position.y].type == type {
				area[position.x][position.y].type = type
			}
		}

	}

	print_area :: proc(area: [dynamic][dynamic]Tile, header: string) {
		fmt.println(header)
		for tiles in area {
			for tile in tiles {
				fmt.printf("%c", tile.pipe)
			}
			fmt.println()
		}
		fmt.println()
	}

	i := 0

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		tiles: [dynamic]Tile

		for character, j in line {
			append(&tiles, Tile{ character, .Unknown })
		}
		append(&area, tiles)
		i += 1
	}

	print_area(area, "Area:")

	horizontal_expansion_area: [dynamic][dynamic]Tile
	defer delete(horizontal_expansion_area)

	for x in 0..<len(area) {

		horizontal_expansion_tiles: [dynamic]Tile

		for y in 0..<len(area[x])-1 {

			pipe := area[x][y].pipe
			next_pipe := area[x][y + 1].pipe
			horizontal_expansion_pipe := '.'
			if pipe == '-' || pipe == 'L' || pipe == 'F' || pipe == 'S' {
				if next_pipe == '-' || next_pipe == '7' || next_pipe == 'J' || next_pipe == 'S' {
					horizontal_expansion_pipe = '-'
				}
			}
			append(&horizontal_expansion_tiles, Tile{ horizontal_expansion_pipe, .Unknown })
		}
		append(&horizontal_expansion_area, horizontal_expansion_tiles)
	}

	print_area(horizontal_expansion_area, "Horizontal Expansion Area:")

	horizontal_interleaved_area: [dynamic][dynamic]Tile
	defer delete(horizontal_interleaved_area)

	for x in 0..<len(area) {
		interleaved_row: [dynamic]Tile
		for y in 0..<len(area[x]) {
			append(&interleaved_row, area[x][y])
			if y < len(horizontal_expansion_area[x]) {
				append(&interleaved_row, horizontal_expansion_area[x][y])
			}
		}
		append(&horizontal_interleaved_area, interleaved_row)
	}

	print_area(horizontal_interleaved_area, "Horizontal Interleaved Area:")

	expansion_area: [dynamic][dynamic]Tile
	defer delete(expansion_area)

	for x in 0..<len(horizontal_interleaved_area)-1 {

		expansion_tiles: [dynamic]Tile

		for y in 0..<len(horizontal_interleaved_area[x]) {

			pipe := horizontal_interleaved_area[x][y].pipe
			next_pipe := horizontal_interleaved_area[x + 1][y].pipe
			expansion_pipe := '.'
			if pipe == '|' || pipe == '7' || pipe == 'F' || pipe == 'S' {
				if next_pipe == '|' || next_pipe == 'L' || next_pipe == 'J' || next_pipe == 'S' {
					expansion_pipe = '|'
				}
			}
			append(&expansion_tiles, Tile{ expansion_pipe, .Unknown })
		}
		append(&expansion_area, expansion_tiles)
	}
	print_area(expansion_area, "Expansion Area:")

	interleaved_area: [dynamic][dynamic]Tile
	defer delete(interleaved_area)

	for x in 0..<len(horizontal_interleaved_area) {
		append(&interleaved_area, horizontal_interleaved_area[x])
		if x < len(expansion_area) {
			append(&interleaved_area, expansion_area[x])
		}
	}
	print_area(interleaved_area, "Interleaved Area:")

	// Find starting location
	start: Position
	for x in 0..<len(interleaved_area) {
		for y in 0..<len(interleaved_area[x]) {
			if interleaved_area[x][y].pipe == 'S' {
				start.x = x
				start.y = y
			}
		}
	}

	bounds := Bounds{ {start.x, start.y}, {start.x, start.y} }

	forward := start
	step(interleaved_area, &forward)

	step_count := 0
	for forward.x != start.x || forward.y != start.y {

		step(interleaved_area, &forward)

		if forward.x < bounds.min.x {
			bounds.min.x = forward.x
		}
		if forward.y < bounds.min.y {
			bounds.min.y = forward.y
		}
		if forward.x > bounds.max.x {
			bounds.max.x = forward.x
		}
		if forward.y > bounds.max.y {
			bounds.max.y = forward.y
		}
		step_count += 1
	}


	// Convert the easy outside tiles
	for tiles, x in interleaved_area {
		for &tile, y in tiles {
			if x < bounds.min.x || y < bounds.min.y || x > bounds.max.x || y > bounds.max.y {
				tile.type = .Outside
			}
			if tile.type != .Unknown {
				continue
			}
			if x == 0 || x == len(interleaved_area) - 1 {
				tile.type = .Outside
			}
			if y == 0 || y == len(interleaved_area[x]) - 1 {
				tile.type = .Outside
			}
		}
	}

	// Convert unknown tiles that are adjacent to an outside tile
	conversion_count := -1
	for conversion_count != 0 {
		conversion_count = 0

		for tiles, x in interleaved_area {
			for &tile, y in tiles {
				if tile.type != .Unknown {
					continue
				}

				convert(&interleaved_area, Position{ x, y, .None }, .Outside)

				if tile.type == .Outside {
					conversion_count += 1
				}
			}
		}

	}

	// Any tile unknown at this point is inside
	for tiles, x in interleaved_area {
		for &tile, y in tiles {
			if tile.type != .Unknown {
				continue
			}
			tile.type = .Inside
		}
	}

	// Remove expansion tiles so we can get an accurate count
	i = 1
	for i < len(interleaved_area) {
		ordered_remove(&interleaved_area, i)
		i += 1
	}
	for &tiles in interleaved_area {
		i = 1
		for i < len(tiles) {
			ordered_remove(&tiles, i)
			i += 1
		}
	}

	fmt.println("Final Area:")
	inside_count := 0
	bold := "\033[1m"
	black := "\033[30m"
	red := "\033[31m"
	red_bg := "\033[41m"
    blue := "\033[34m"
	blue_bg := "\033[44m"
    reset := "\033[0m"
	for tiles, x in interleaved_area {
		for tile, y in tiles {


			if tile.type == .Inside {
				fmt.printf("%s%s%s%c%s", bold, black,red_bg, 'I', reset)
				inside_count += 1
			}
			else if tile.type == .Outside {
				fmt.printf("%s%s%s%c%s", bold, black, blue_bg, 'O', reset)
			}
			else {
				fmt.printf("%c", tile.pipe)
			}
		}
		fmt.println()
	}

	fmt.println()
	fmt.println(inside_count)

}
