package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

run_day4_part2 :: proc() {

	LineState :: enum {
		CardIdWaiting,
		CardIdPopulating,
		WinningNumberWaiting,
		WinningNumberPopulating,
		YourNumberWaiting,
		YourNumberPopulating,
	}

	filepath := "4_input.txt"

	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	card_instance_map := make(map[int]int)
	defer delete(card_instance_map)
	winning_numbers: [dynamic]int
	defer delete(winning_numbers)
	your_numbers: [dynamic]int
	defer delete(your_numbers)
	last_card_id: int = -1

	it := string(data)
	for line in strings.split_lines_iterator(&it) {

		clear(&winning_numbers)
		clear(&your_numbers)

		line_state: LineState = .CardIdWaiting
		start: int = -1
		card_id: int = -1

		// For loop's sole purpose is to extract data from the input
		for character, i in line {

			is_digit := '0' <= character && character <= '9'
			is_last := i == len(line) - 1

			switch line_state {
			case .CardIdWaiting:
				if is_digit {
					start = i
					line_state = .CardIdPopulating
				}
			case .CardIdPopulating:
				if character == ':' {
					card_id = strconv.atoi(line[start : i])
					line_state = .WinningNumberWaiting
				}
			case .WinningNumberWaiting:
				if is_digit {
					start = i
					line_state = .WinningNumberPopulating
				}
				else if character == '|' {
					line_state = .YourNumberWaiting
				}
			case .WinningNumberPopulating:
				if !is_digit {
					number := strconv.atoi(line[start : i])
					append(&winning_numbers, number)
					line_state = .WinningNumberWaiting
				}
			case .YourNumberWaiting:
				if is_digit {
					start = i
					if is_last {
						number := strconv.atoi(line[start : i + 1])
						append(&your_numbers, number)
					}
					line_state = .YourNumberPopulating
				}
			case .YourNumberPopulating:
				if !is_digit || is_last {
					substring := line[start : i]
					if is_last {
						substring = line[start : i + 1]
					}
					number := strconv.atoi(substring)
					append(&your_numbers, number)
					line_state = .YourNumberWaiting
				}
			}
		}

		match_count := 0
		for your_number in your_numbers {
			for winning_number in winning_numbers {
				if your_number == winning_number {
					match_count += 1
				}
			}
		}

		if card_id in card_instance_map {
			card_instance_map[card_id] += 1
		}
		else {
			card_instance_map[card_id] = 1
		}

		copy_count := card_instance_map[card_id]
		for i in 1..=match_count {
			card_id_to_copy := card_id + i  
			if card_id_to_copy in card_instance_map {
				card_instance_map[card_id_to_copy] += copy_count
			}
			else {
				card_instance_map[card_id_to_copy] = copy_count 
			}
		}

		last_card_id = card_id
	}

	instance_sum := 0
	for key in card_instance_map {

		// Ignore instances of cards that do not exist in the input
		if key > last_card_id {
			continue
		}

		instance_sum += card_instance_map[key]
	}
	fmt.println()
	fmt.println(instance_sum)
}

