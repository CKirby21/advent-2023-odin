package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"
import "core:strconv"

run_day3_part2 :: proc() {

	Number :: struct {
		line_num: int,
		index_in_line: int,
		value: string,
		is_part: bool
	}

	Symbol :: struct {
		line_num: int,
		index_in_line: int,
		value: u8,
		adjacent_part_values: [dynamic]int
	}

	LineState :: enum{
		NumberWaiting, 
		NumberPopulating
	}

	numbers: [dynamic]Number
	defer delete(numbers)

	symbols: [dynamic]Symbol
	defer delete(symbols)

	filepath := "3_input.txt"

	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	line_num := 0

	// I should have just put all the characters from the input in a dynamic 2d
	// array and then query that
	it := string(data)
	for line in strings.split_lines_iterator(&it) {

		start := -1
		num := -1
		line_state: LineState = .NumberWaiting

		for i := 0; i < len(line); i += 1 {

			ascii := int(line[i])
			is_digit := 47 < ascii && ascii < 58
			is_lowercase := 96 < ascii && ascii < 123
			is_symbol := line[i] == '*' || line[i] == '/' || line[i] == '+' || line[i] == '-' || line[i] == '=' || line[i] == '$' || line[i] == '%' || line[i] == '#' || line[i] == '&' || line[i] == '@'

			if is_symbol {
				adjacent_part_values: [dynamic]int
				append(
					&symbols, 
					Symbol{ line_num, i, line[i], adjacent_part_values }
				)
			}

			switch line_state {
			case .NumberWaiting:
				if is_digit {
					start = i
					line_state = .NumberPopulating
				}
			case .NumberPopulating:
				is_last := i == len(line) - 1
				if !is_digit || is_last {
					substring := line[start : i]
					if is_last && is_digit {
						substring = line[start : i + 1]
					}
					append(
						&numbers, 
						Number{ line_num, start, substring, false }
					)
					line_state = .NumberWaiting
				}
			}
		}

		line_num += 1
	}

	for &symbol in symbols {

		for &number in numbers {

			symbol_on_adjacent_line := symbol.line_num - 1 <= number.line_num && number.line_num <= symbol.line_num + 1
			if !symbol_on_adjacent_line {
				continue
			}

			length := len(number.value)

			for i := 0; i < len(number.value); i += 1 {
				index_in_line := number.index_in_line + i
				symbol_on_adjacent_index := symbol.index_in_line - 1 <= index_in_line && index_in_line <= symbol.index_in_line + 1

				// fmt.println(symbol.value, number.value, symbol.index_in_line - 1, "<=", index_in_line, symbol.index_in_line, symbol_on_adjacent_index)
				if symbol_on_adjacent_index {
					number.is_part = true
					append(&symbol.adjacent_part_values, strconv.atoi(number.value))
					break
				}

			}
		}
	}

	gear_ratio_sum := 0
	for symbol in symbols {
		if symbol.value == '*' && len(symbol.adjacent_part_values) == 2 {
			gear_ratio := symbol.adjacent_part_values[0] * symbol.adjacent_part_values[1]
			gear_ratio_sum += gear_ratio
		}
	}

	fmt.println()
	fmt.println(gear_ratio_sum)

	for &symbol in symbols {
		delete(symbol.adjacent_part_values)
	}
}
