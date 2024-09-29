package main

import "core:fmt"
import "core:strings"
import "core:os"
import "core:thread"
import "core:time"
import "core:sync"

///////////////////////////////////////////////////////////////////////
// Globals
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
// Types
///////////////////////////////////////////////////////////////////////

@(private="file")
Worker :: struct {
	node: ^string,
	instructions: string,
	graph: map[string][2]string,
	work: bool,
	step_count: i64,
	mutex: ^sync.Mutex,
	step_to_ends: ^map[i64]int
}

///////////////////////////////////////////////////////////////////////
// Procedures
///////////////////////////////////////////////////////////////////////

is_end :: proc(node: string) -> bool {
	return strings.has_suffix(node, "Z")
}

are_end :: proc(nodes: [dynamic]string) -> bool {
	end := true
	for node in nodes {
		if !is_end(node) {
			end = false
		}
	}
	return end

}

@(private="file")
worker_proc :: proc(data: rawptr) {
	worker := cast(^Worker)data

	for worker.work {

		edges := worker.graph[worker.node^]
		index := worker.step_count % i64(len(worker.instructions))
		instruction := worker.instructions[index]

		if instruction == 'L' {
			worker.node^ = edges[0]
		}
		else {
			worker.node^ = edges[1]
		}

		if is_end(worker.node^) {
			sync.lock(worker.mutex)
			if !(worker.step_count in worker.step_to_ends) {
				worker.step_to_ends[worker.step_count] = 0
			}
			worker.step_to_ends[worker.step_count] += 1
			sync.unlock(worker.mutex)
		}
		worker.step_count += 1
	}

}

///////////////////////////////////////////////////////////////////////
// Main
///////////////////////////////////////////////////////////////////////

run_day8_part2 :: proc() {

	filepath := "8_input.txt"
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	starting_nodes: [dynamic]string
	defer delete(starting_nodes)

	graph: map[string][2]string
	defer delete(graph)

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

		if strings.has_suffix(node, "A") {
			append(&starting_nodes, node)
		}

		graph[node] = [2]string{left, right}
	}

	nodes: [dynamic]string
	defer delete(nodes)

	append(&nodes, ..starting_nodes[:])

	fmt.println(nodes)
	fmt.println()

	work := true
	mutex: sync.Mutex

	step_to_ends: map[i64]int
	defer delete(step_to_ends)

	workers: [dynamic]Worker
	defer delete(workers)
	for i in 0..<len(nodes) {
		worker := Worker{ 
			&nodes[i], 
			instructions, 
			graph,
			work,
			0,
			&mutex,
			&step_to_ends
		}
		append(&workers, worker)
	}

	for i in 0..<len(workers) {
		thread.run_with_data(&workers[i], worker_proc)
	}

	end_step_count: i64 = 9_223_372_036_854_775_807
	deletes: [dynamic]i64
	defer delete(deletes)

	collection := time.now()

	for work {

		if time.duration_seconds(time.since(collection)) < 10 {
			continue
		}
		collection = time.now()

		sync.lock(&mutex)

		max_step_count: i64 = 0
		min_step_count: i64 = 9_223_372_036_854_775_807

		for worker in workers {
			if worker.step_count > max_step_count {
				max_step_count = worker.step_count
			}
			if worker.step_count < min_step_count {
				min_step_count = worker.step_count
			}
		}

		max_end_count := 0
		for step_count, end_count in step_to_ends {

			if end_count > max_end_count {
				max_end_count = end_count
			}	

			if end_count == len(workers) {
				if step_count < end_step_count {
					end_step_count = step_count 
					work = false
				}
			}
		}

		// Garbage Collection
		for step_count, end_count in step_to_ends {
			if step_count < min_step_count {
				append(&deletes, step_count)
			}
		}
		fmt.printf("Deleting %d...\n", len(deletes))
		for key in deletes {
			delete_key(&step_to_ends, key)
		}
		clear(&deletes)

		fmt.printf("%d %d %d %d\n", max_end_count, len(step_to_ends), min_step_count, max_step_count)
		sync.unlock(&mutex)
	}

	fmt.println()
	fmt.println(end_step_count)
	work = false
}

