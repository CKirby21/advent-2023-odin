package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"
import "core:strconv"

run_day2_part1 :: proc() {

	LineState :: enum{
		GameIdWaiting, 
		GameIdPopulating, 
		NumberWaiting,
		NumberPopulating,
		ColorWaiting,
		ColorPopulating
	}

	bag_map := map[string]int{
		"red" = 12,
		"green" = 13, 
		"blue" = 14, 
	}
	defer delete(bag_map)

	filepath := "2_input.txt"

	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	game_id_sum := 0

	it := string(data)
	for line in strings.split_lines_iterator(&it) {

		start := -1
		game_id := -1
		num := -1
		possible := true
		line_state: LineState = .GameIdWaiting

		for i := 0; i < len(line); i += 1 {

			ascii := int(line[i])
			is_digit := 47 < ascii && ascii < 58
			is_lowercase := 96 < ascii && ascii < 123

			switch line_state {
			case .GameIdWaiting:
				if is_digit {
					start = i
					line_state = .GameIdPopulating
				}
			case .GameIdPopulating:
				if !is_digit {
					game_id = strconv.atoi(line[start : i])
					line_state = .NumberWaiting
				}
			case .NumberWaiting:
				if is_digit {
					start = i
					line_state = .NumberPopulating
				}
			case .NumberPopulating:
				if !is_digit {
					num = strconv.atoi(line[start : i])
					line_state = .ColorWaiting
				}
			case .ColorWaiting:
				if is_lowercase {
					start = i
					line_state = .ColorPopulating
				}
			case .ColorPopulating:
				is_last := i == len(line) - 1
				if !is_lowercase || is_last {
					color := line[start : i]
					if is_last {
						color = line[start : i + 1]
					}
					if num > bag_map[color] {
						possible = false
					}
					line_state = .NumberWaiting
				}
			}
			// fmt.println(game_id, line_state, num, start)
		}

		fmt.println(possible, game_id)

		if possible {
			game_id_sum += game_id
		}
	}

	fmt.println()
	fmt.println(game_id_sum)
}
