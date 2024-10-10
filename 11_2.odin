package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"
import "core:unicode/utf8"

run_day11_part2 :: proc() {

	filepath := "11_input.txt"
	fmt.println(filepath)
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

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

	expand :: proc(index_list: [dynamic]int, bound1: int, bound2: int) -> (addon: int) {

		expansion_coefficient := 1_000_000

		lower := bound1
		higher := bound2
		if bound2 < bound1 {
			lower = bound2
			higher = bound1
		}

		for index in index_list {
			if lower < index && index < higher {
				addon += expansion_coefficient - 1
			}
		}

		return addon
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

	print_universe(universe, "Universe:")

	empty_rows: [dynamic]int
	defer delete(empty_rows)
	empty_cols: [dynamic]int
	defer delete(empty_cols)

	for row, i in universe {
		row_str := utf8.runes_to_string(row)
		if !strings.contains(row_str, "#") {
			append(&empty_rows, i)
		}
	}

	// We transpose because it is much easier to see if a row is empty vs a column
	transpose(&universe)

	for row, i in universe {
		row_str := utf8.runes_to_string(row)
		if !strings.contains(row_str, "#") {
			append(&empty_cols, i)
		}
	}

	// Transpose back to the original universe
	transpose(&universe)

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

			rise := galaxies[j].x - galaxies[i].x
			rise_addon := expand(empty_rows, galaxies[i].x, galaxies[j].x)

			run := galaxies[j].y - galaxies[i].y
			run_addon := expand(empty_cols, galaxies[i].y, galaxies[j].y)

			length := math.abs(rise) + rise_addon + math.abs(run) + run_addon
			length_sum += length
		}
	}

	fmt.println()
	fmt.println(length_sum)

}

