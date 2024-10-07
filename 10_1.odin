package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"

run_day10_part1 :: proc() {

	filepath := "10_input.txt"
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	area: [dynamic][dynamic]rune
	defer delete(area)

	Direction :: enum {
		None,
		North,
		East,
		South,
		West
	}

	Position :: struct {
		x: int,
		y: int,
		direction: Direction
	}

	out_of_bounds :: proc(i: int, length: int) -> bool {

		if i < 0 || i >= length {
			return true
		}
		return false
	}

	opposite_direction :: proc(direction: Direction) -> (opposite: Direction) {
		switch direction {
		case .North:
			opposite = .South
		case .East:
			opposite = .West
		case .South:
			opposite = .North
		case .West:
			opposite = .East
		case .None:
			opposite = .None
		}
		return opposite

	}

	valid_pipe :: proc(area: [dynamic][dynamic]rune, current: Position, direction: Direction) -> (Position, bool) {

		next := current
		next.direction = direction

		switch direction {
		case .North:
			next.x -= 1
		case .East:
			next.y += 1
		case .South:
			next.x += 1
		case .West:
			next.y -= 1
		case .None:
			panic("Direction should never be none here")
		}

		// Order matters here
		if out_of_bounds(next.x, len(area)) || out_of_bounds(next.y, len(area[next.x])) {
			return next, false
		}

		pipe := area[next.x][next.y]
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

	step :: proc(area: [dynamic][dynamic]rune, position: ^Position) {

		explored_direction := opposite_direction(position.direction)
		directions := get_directions(area[position.x][position.y])

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

	start: Position
	i := 0

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		runes: [dynamic]rune

		for character, j in line {
			if character == 'S' {
				start.x = i
				start.y = j
			}
			append(&runes, character)
		}
		append(&area, runes)
		i += 1
	}

	forward := start
	step(area, &forward)

	step_count := 0
	for forward.x != start.x || forward.y != start.y {

		step(area, &forward)
		step_count += 1
	}

	fmt.println()
	fmt.println(math.ceil( f64(step_count) / 2.0 ))

}
