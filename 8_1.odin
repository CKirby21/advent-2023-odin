package main

import "core:fmt"
import "core:strings"
import "core:os"
import "core:strconv"
import "core:math"
import "core:testing"
import "core:log"

///////////////////////////////////////////////////////////////////////
// Globals
///////////////////////////////////////////////////////////////////////

@(private="file")
graph: map[string][2]string

///////////////////////////////////////////////////////////////////////
// Types
///////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////
// Procedures
///////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////
// Main
///////////////////////////////////////////////////////////////////////

run_day8_part1 :: proc() {

	filepath := "8_input.txt"
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	instructions := ""

	it := string(data)
	for line in strings.split_lines_iterator(&it) {

		line_parts := strings.fields(line)
		if len(line_parts) == 0 {
			continue
		}
		else if len(line_parts) == 1 {
			instructions = line_parts[0]
			continue
		}

		for part, i in line_parts {
			trimmed_part := strings.trim(part, " ()=,")
			line_parts[i] = trimmed_part
		}

		assert(line_parts[1] == "")
		assert(len(line_parts) == 4)

		node := line_parts[0]
		left := line_parts[2]
		right := line_parts[3]
		graph[node] = [2]string{left, right}
	}

	fmt.println(graph)

	starting_node := "AAA"
	ending_node := "ZZZ"
	node := starting_node
	step_count := 0

	for node != ending_node {

		edges := graph[node]
		index := step_count % len(instructions)
		instruction := instructions[index]

		fmt.printf("%s: (%s, %s) %c\n", node, edges[0], edges[1], instruction)

		if instruction == 'L' {
			node = edges[0]
		}
		else {
			node = edges[1]
		}

		step_count += 1
	}

	fmt.println()
	fmt.println(step_count)

}

