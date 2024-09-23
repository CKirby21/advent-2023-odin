package main 

import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"

contains :: proc(line: string, substring: string) -> [dynamic]int {

	indexes: [dynamic]int

	for i := 0; i < len(line); i += 1 {

		found_substring := true

		for j := 0; j < len(substring); j += 1 {

			if i + j >= len(line) {
				found_substring = false
				break
			}

			if line[i + j] != substring[j]{
				found_substring = false
				break
			}
		}

		if found_substring {
			append(&indexes, i)
		}

	}
	// Don't know if i can return this within a function without memory leakage
	return indexes
}

@(test)
test_contains_positive :: proc(t: ^testing.T) {
	line := "pffldcmnlpsevensixqxhdncrclbc51five"

    indexes := contains(line, "five")
    testing.expect_value(t, len(indexes), 1)
    testing.expect_value(t, indexes[0], 31)

    indexes = contains(line, "seven")
    testing.expect_value(t, len(indexes), 1)
    testing.expect_value(t, indexes[0], 10)
}

@(test)
test_contains_negative :: proc(t: ^testing.T) {
	line := "pffldcmnlpsevensixqxhdncrclbc51five"

    indexes := contains(line, "eight")
    testing.expect_value(t, len(indexes), 0)

    indexes = contains(line, "9")
    testing.expect_value(t, len(indexes), 0)
}

run_day1_part2 :: proc() {

	filepath := "1_input.txt"

	digit_map := map[string]int{
		"zero" = 0,
		"one" = 1, 
		"two" = 2, 
		"three" = 3, 
		"four" = 4, 
		"five" = 5, 
		"six" = 6,
		"seven" = 7,
		"eight" = 8,
		"nine" = 9,
		"0" = 0,
		"1" = 1, 
		"2" = 2, 
		"3" = 3, 
		"4" = 4, 
		"5" = 5, 
		"6" = 6,
		"7" = 7,
		"8" = 8,
		"9" = 9
	}
	defer delete(digit_map)

	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	calibration_value_sum := 0

	it := string(data)
	for line in strings.split_lines_iterator(&it) {

		first_index := len(line)
		first_key := ""

		last_index := -1
		last_key := "" 

		for key in digit_map {

			indexes := contains(line, key)

			for i in indexes {
				if i < first_index {
					first_index = i
					first_key = key
				}
				if i > last_index {
					last_index = i
					last_key = key
				}
			}
		}

		first_digit := digit_map[first_key]
		last_digit := digit_map[last_key]

		calibration_value := (first_digit * 10) + last_digit
		calibration_value_sum += calibration_value

		fmt.println(line, first_digit, last_digit, calibration_value)
	}

	fmt.println()
	fmt.println(calibration_value_sum)
}
