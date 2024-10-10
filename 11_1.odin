package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"
import "core:unicode/utf8"

run_day11_part1 :: proc() {

	filepath := "11_input.txt"
	fmt.println(filepath)
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	expand :: proc(universe: ^[dynamic][]rune) {

		i := 0
		for i < len(universe) {
			row := utf8.runes_to_string(universe[i])
			if !strings.contains(row, "#") {
				inject_at(universe, i, universe[i])
				i += 1
			}
			i += 1
		}
	}

	alloc_2d :: proc(universe: ^[dynamic][]rune, r: int, c: int) {
		universe^ = make([dynamic][]rune, r)
		for i in 0..<r {
			universe[i] = make([]rune, c)
		}
		assert(len(universe) == r) 
		assert(len(universe[0]) == c) 
	}

	transpose :: proc(universe: ^[dynamic][]rune) {
		transposed_universe: [dynamic][]rune

		r := len(universe)
		c := len(universe[0])
		alloc_2d(&transposed_universe, c, r)

		for i in 0..<r {
			for j in 0..<c {
				transposed_universe[j][i] = universe[i][j]
			}
		}
		free(universe)
		universe^ = transposed_universe
	}

	print_universe :: proc(universe: [dynamic][]rune, header: string) {

		fmt.println(header)
		for row in universe {
			for char in row {
				fmt.print(char)
			}
			fmt.println()
		}
		fmt.println()
	}

	universe: [dynamic][]rune
	defer delete(universe)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {

		append(&universe, utf8.string_to_runes(line))
		
	}

	print_universe(universe, "Input:")
	expand(&universe)
	print_universe(universe, "Expanded:")
	transpose(&universe)
	print_universe(universe, "Transposed:")
	expand(&universe)
	print_universe(universe, "Expanded:")
	transpose(&universe)
	print_universe(universe, "Transposed:")

	galaxies: [dynamic][2]int
	defer delete(galaxies)

	for row, x in universe {
		for char, y in row {
			if char == '#' {
				append(&galaxies, [?]int{x, y})
			}
		}
	}

	length_sum := 0
	// Iterate over unique combinations of galaxies
	for i in 0..<len(galaxies) {
		for j in i+1..<len(galaxies) {
			rise := galaxies[j].y - galaxies[i].y
			run := galaxies[j].x - galaxies[i].x
			length := math.abs(rise) + math.abs(run)
			length_sum += length
		}
	}

	fmt.println()
	fmt.println(length_sum)

}

