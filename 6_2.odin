package main

import "core:fmt"
import "core:strings"
import "core:os"
import "core:strconv"
import "core:math"

run_day6_part2 :: proc() {

	determine_win :: proc(hold_time: int, race: Race) -> (win: bool) {

		move_time := race.time - hold_time 

		distance := 0
		speed := hold_time 
		for i in 0..<move_time {
			distance += speed
		}

		win = distance > race.distance
		return win
	}

	print_progress :: proc(completed: int, total: int, win: bool) {
		complete_percent := ( f64(completed) / f64(total) ) * 100.0
		fmt.printf("\r%.2f%% %v (%d / %d)", complete_percent, win, completed, total)
	}

	get_inflection_hold_time :: proc(race: Race, loser: HoldTimeToWinItem, winner: HoldTimeToWinItem) -> (hold_time: int) {
		direction := 1 if loser.hold_time < winner.hold_time else -1
		inflection := "start" if direction > 0 else "stop"
		fmt.println()
		fmt.printf("Finding winning hold time %s...\n", inflection)
		win := loser.win 
		hold_time = loser.hold_time 
		completed := -1
		total := -1
		for win == loser.win {
			win = determine_win(hold_time, race)
			completed = math.abs(hold_time - loser.hold_time)
			total = math.abs(winner.hold_time - loser.hold_time)
			print_progress(completed, total, win)
			hold_time += direction
		}
		hold_time -= direction
		print_progress(total, total, win)
		fmt.println()
		fmt.printf("Winning hold time %s: %d\n", inflection, hold_time)
		return hold_time
	}

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

	race: Race

	it := string(data)
	for line in strings.split_lines_iterator(&it) {

		line_parts := strings.fields(line)
		if line_parts[0] == "Time:" {
			time := strings.join(line_parts[1:], "")
			race.time = strconv.atoi(time)
		}
		else if line_parts[0] == "Distance:" {
			distance := strings.join(line_parts[1:], "")
			race.distance = strconv.atoi(distance)
		}
	}

	fmt.println("Race time:", race.time)
	fmt.println("Race distance:", race.distance)
	fmt.println()

	HoldTimeToWinItem :: struct {
		hold_time: int,
		win: bool
	}

	hold_time_to_win_items: [dynamic]HoldTimeToWinItem
	defer delete(hold_time_to_win_items)

	prev_item := HoldTimeToWinItem{-1, false}
	hold_time := 0
	win := false
	step := race.time / 10000

	fmt.println("Populating hold time to win items...")

	for hold_time <= race.time {

		win = determine_win(hold_time, race)
		item := HoldTimeToWinItem{ hold_time, win }
		if !prev_item.win && item.win || prev_item.win && !item.win {
			append(&hold_time_to_win_items, prev_item, item)
		}

		print_progress(hold_time, race.time, win)

		hold_time += step 
		prev_item = item
	}
	print_progress(race.time, race.time, win)
	fmt.println()

	assert(len(hold_time_to_win_items) == 4)
	assert(hold_time_to_win_items[0].win == false)
	assert(hold_time_to_win_items[1].win == true)
	assert(hold_time_to_win_items[2].win == true)
	assert(hold_time_to_win_items[3].win == false)

	fmt.println()
	fmt.println("Hold time to win items:")
	for item in hold_time_to_win_items {
		fmt.println("\t", item.hold_time, item.win)
	}

	winning_hold_time_start := get_inflection_hold_time(
		race,
		hold_time_to_win_items[0], 
		hold_time_to_win_items[1]
	)

	winning_hold_time_stop := get_inflection_hold_time(
		race,
		hold_time_to_win_items[3], 
		hold_time_to_win_items[2]
	)

	win_count := winning_hold_time_stop - winning_hold_time_start + 1
	fmt.println()
	fmt.println(win_count)
}
