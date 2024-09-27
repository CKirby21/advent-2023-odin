package main

import "core:fmt"
import "core:os"

main :: proc() {
	
	program := os.args[0]

	fmt.println(os.args)

	if len(os.args) != 3 {
		fmt.printf("USAGE: %s DAY PART\n", program) 
		return 
	}
	
	day := os.args[1]
	part := os.args[2]

	fmt.printf("Running day %s part %s\n\n", day, part) 

	switch day {
	case "1":
		if part == "1" {
			run_day1_part1()
		}
		else {
			run_day1_part2()
		}
	case "2":
		if part == "1" {
			run_day2_part1()
		}
		else {
			run_day2_part2()
		}
	case "3":
		if part == "1" {
			run_day3_part1()
		}
		else {
			run_day3_part2()
		}
	case "4":
		if part == "1" {
			run_day4_part1()
		}
		else {
			run_day4_part2()
		}
	case "5":
		if part == "1" {
			run_day5_part1()
		}
		else {
			run_day5_part2()
		}
	case "6":
		if part == "1" {
			run_day6_part1()
		}
		else {
			run_day6_part2()
		}
	case "7":
		if part == "1" {
			run_day7_part1()
		}
		else {
			run_day7_part2()
		}
	}

}
