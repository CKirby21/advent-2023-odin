package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

run_day5_part2 :: proc() {

	LineState :: enum {
		NumberWaiting,
		NumberPopulating
	}

	State :: enum {
		Seeds,
		SeedToSoil,
		SoilToFertilizer,
		FertilizerToWater,
		WaterToLight,
		LightToTemperature,
		TemperatureToHumidity,
		HumidityToLocation,
	}

	Thing :: struct {
		destination_range_start: int,
		source_range_start: int,
		range_length: int
	}

	contains :: proc(line: string, substring: string) -> bool {

		found_substring := false

		if len(substring) > len(line) {
			return found_substring
		}

		for i in 0..<len(line) {

			found_substring_here := true
			for j in 0..<len(substring) {

				if i + j >= len(line) {
					break
				}

				if line[i + j] != substring[j] {
					found_substring_here = false
				}
			}
			if found_substring_here {
				found_substring = true
			}
		}
		return found_substring
	}

	lookup :: proc(things: [dynamic]Thing, source: int) -> (destination: int) {

		// Any source numbers that aren't mapped correspond to 
		// the same destination number. 
		destination = source

		for thing in things {

			source_range_stop := thing.source_range_start + thing.range_length
			if thing.source_range_start <= source && source < source_range_stop {

				source_position := source - thing.source_range_start
				destination = thing.destination_range_start + source_position 
			}
		}

		return destination
	}

	filepath := "5_input.txt"

	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	state: State = .Seeds
	seeds: [dynamic]int
	defer delete(seeds)
	numbers: [dynamic]int
	defer delete(numbers)
	seed_to_soil_things: [dynamic]Thing
	defer delete(seed_to_soil_things)
	soil_to_fertilizer_things: [dynamic]Thing
	defer delete(soil_to_fertilizer_things)
	fertilizer_to_water_things: [dynamic]Thing
	defer delete(fertilizer_to_water_things)
	water_to_light_things: [dynamic]Thing
	defer delete(water_to_light_things)
	light_to_temperature_things: [dynamic]Thing
	defer delete(light_to_temperature_things)
	temperature_to_humidity_things: [dynamic]Thing
	defer delete(temperature_to_humidity_things)
	humidity_to_location_things: [dynamic]Thing
	defer delete(humidity_to_location_things)

	fmt.println("Parsing input...")
	it := string(data)
	for line in strings.split_lines_iterator(&it) {

		clear(&numbers)

		if line == "" {
			continue
		}

		if contains(line, "seed-to-soil") {
			state = .SeedToSoil
		}
		else if contains(line, "soil-to-fertilizer") {
			state = .SoilToFertilizer
		}
		else if contains(line, "fertilizer-to-water") {
			state = .FertilizerToWater
		}
		else if contains(line, "water-to-light") {
			state = .WaterToLight
		}
		else if contains(line, "light-to-temperature") {
			state = .LightToTemperature
		}
		else if contains(line, "temperature-to-humidity") {
			state = .TemperatureToHumidity
		}
		else if contains(line, "humidity-to-location") {
			state = .HumidityToLocation
		}

		line_state: LineState = .NumberWaiting
		start: int = -1

		for character, i in line {

			is_digit := '0' <= character && character <= '9'
			is_last := i == len(line) - 1

			switch line_state {
			case .NumberWaiting:
				if is_digit {
					start = i 
					if is_last {
						number := strconv.atoi(line[i : i + 1])
						append(&numbers, number)
					}
					else {
						line_state = .NumberPopulating
					}
				}
			case .NumberPopulating:
				if !is_digit || is_last {
					substring := line[start : i]
					if is_last {
						substring = line[start : i + 1]
					}

					number := strconv.atoi(substring)
					append(&numbers, number)
					line_state = .NumberWaiting
				}
			}
		}

		if state == .Seeds {
			fmt.println("Gathering seeds...")

			populating_range_start := true
			range_start: int = -1
			for number, i in numbers {

				percentage_complete := f64(i) / f64(len(numbers) - 1) * 100.0
				fmt.printf("\r%.1f%%", percentage_complete)

				if populating_range_start {
					range_start = number
				}
				else {
					range_length := number
					for i in 0..<range_length {
						seed := range_start + i
						append(&seeds, seed)
					}
				}
				populating_range_start = !populating_range_start
			}
			fmt.println()
			fmt.println("Finished gathering", len(seeds), "seeds")
		}

		if len(numbers) == 3 {

			thing: Thing = {
				numbers[0],
				numbers[1],
				numbers[2]
			}

			switch state {
			case .Seeds:
			case .SeedToSoil:
				append(&seed_to_soil_things, thing)
			case .SoilToFertilizer:
				append(&soil_to_fertilizer_things, thing)
			case .FertilizerToWater:
				append(&fertilizer_to_water_things, thing)
			case .WaterToLight:
				append(&water_to_light_things, thing)
			case .LightToTemperature:
				append(&light_to_temperature_things, thing)
			case .TemperatureToHumidity:
				append(&temperature_to_humidity_things, thing)
			case .HumidityToLocation:
				append(&humidity_to_location_things, thing)
			}
		}
	}

	fmt.println("Finished parsing input")
	
	fmt.println("Looking up locations...")
	location_min := 9_223_372_036_854_775_807
	for seed, i in seeds {

		if i % 1_000_000 == 0 {
			percentage_complete := f64(i) / f64(len(seeds) - 1) * 100.0
			fmt.printf("\r%.1f%%", percentage_complete)
		}
		soil := lookup(seed_to_soil_things, seed)
		fertilizer := lookup(soil_to_fertilizer_things, soil)
		water := lookup(fertilizer_to_water_things, fertilizer)
		light := lookup(water_to_light_things, water)
		temperature := lookup(light_to_temperature_things, light)
		humidity := lookup(temperature_to_humidity_things, temperature)
		location := lookup(humidity_to_location_things, humidity)

		// fmt.println(seed, soil, fertilizer, water, light, temperature, humidity, location)
		if location < location_min {
			location_min = location
		}
	}
	fmt.println()
	fmt.println("Finished looking up locations")

	fmt.println()
	fmt.println(location_min)

}
