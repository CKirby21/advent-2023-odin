package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:math"

run_day9_part2 :: proc() {

	filepath := "9_input.txt"
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	History :: struct {
		sequences: [dynamic][dynamic]int
	}
	histories: [dynamic]History
	defer delete(histories)

	all_zeros :: proc(history: History) -> bool {
		rtn := true
		last_sequence := history.sequences[len(history.sequences) - 1]
		for num in last_sequence {
			if num != 0 {
				rtn = false
			}
		}
		return rtn
	}

	// Get data from input file
	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		fields := strings.fields(line)
		sequence: [dynamic]int

		for field in fields {
			num := strconv.atoi(field)
			append(&sequence, num)
		}

		history := History{ }
		append(&history.sequences, sequence)
		append(&histories, history)
		clear(&sequence)
	}

	// Populate difference sequences
	for &history in histories {
		i := 0
		for !all_zeros(history) {

			assert(i == len(history.sequences) - 1)

			sequence: [dynamic]int
			for j in 0..<len(history.sequences[i]) - 1 {
				difference := history.sequences[i][j + 1] - history.sequences[i][j]
				append(&sequence, difference)
			}

			append(&history.sequences, sequence)
			i += 1
		}
	}

	values_sum := 0
	for history in histories {

		value := 0

		#reverse for sequence in history.sequences {
			first_num := sequence[0]
			value = first_num - value
		}

		// fmt.println(value)
		values_sum += value
	}

	fmt.println()
	fmt.println(values_sum)
}
