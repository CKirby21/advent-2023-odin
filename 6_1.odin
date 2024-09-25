package main

import "core:fmt"
import "core:strings"
import "core:os"
import "core:strconv"

run_day6_part1 :: proc() {

	Race :: struct {
		time: int,
		distance: int
	}

	filepath := "6_input.txt"
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	races: [dynamic]Race
	defer delete(races)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {

		line_parts := strings.fields(line)
		if line_parts[0] == "Time:" {
			for part in line_parts[1:] {
				number := strconv.atoi(part)
				append(&races, Race{number, -1})
			}
		}
		else if line_parts[0] == "Distance:" {
			for part, i in line_parts[1:] {
				number := strconv.atoi(part)
				races[i].distance = number
			}
		}
	}

	win_product := 1

	for race in races {
		win_count := 0

		for i in 0..=race.time {
			hold_time := i
			move_time := race.time - hold_time 

			distance := 0
			speed := hold_time 
			for j in 0..<move_time {
				distance += speed
			}

			if distance > race.distance {
				win_count += 1
			}
			// fmt.println(hold_time, distance)
		}
		fmt.println(race.time, win_count)
		win_product *= win_count
	}
	fmt.println()
	fmt.println(win_product)
}
