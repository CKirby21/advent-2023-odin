package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

run_day4_part1 :: proc() {

	LineState :: enum {
		Waiting,
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

	winning_numbers: [dynamic]int
	defer delete(winning_numbers)
	your_numbers: [dynamic]int
	defer delete(your_numbers)
	points_sum := 0

	it := string(data)
	for line in strings.split_lines_iterator(&it) {

		clear(&winning_numbers)
		clear(&your_numbers)

		line_state: LineState = .Waiting
		start: int = -1

		for character, i in line {

			is_digit := '0' <= character && character <= '9'
			is_last := i == len(line) - 1

			switch line_state {
			case .Waiting:
				if character == ':' {
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

		points := 0
		for your_number in your_numbers {
			for winning_number in winning_numbers {
				if your_number == winning_number {
					if points == 0 {
						points = 1
					}
					else {
						points *= 2
					}
				}
			}
		}
		points_sum += points
		fmt.println(points, winning_numbers, your_numbers)
	}

	fmt.println()
	fmt.println(points_sum)
}

