package main 

import "core:fmt"
import "core:os"
import "core:strings"

run_day1_part1 :: proc() {

	filepath := "1_input.txt"

	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	calibration_value_sum := 0

	it := string(data)
	for line in strings.split_lines_iterator(&it) {

		first_digit: int = -1
		last_digit: int = -1

		for character in line {

			character_ascii := int(character)
			zero_ascii := 48
			digit := character_ascii - zero_ascii

			if 0 <= digit && digit <= 9 {

				if first_digit == -1 {
					first_digit = digit 
				}

				last_digit = digit
			}
		}

		calibration_value := (first_digit * 10) + last_digit
		calibration_value_sum += calibration_value

		fmt.println(line, first_digit, last_digit, calibration_value)
	}

	fmt.println()
	fmt.println(calibration_value_sum)
}
