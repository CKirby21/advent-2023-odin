package main

import "core:fmt"
import "core:strings"
import "core:os"
import "core:strconv"
import "core:math"

@(private="file")
label_to_strength := map[u8]int{
	'2' = 2,
	'3' = 3,
	'4' = 4,
	'5' = 5,
	'6' = 6,
	'7' = 7,
	'8' = 8,
	'9' = 9,
	'T' = 10,
	'J' = 11,
	'Q' = 12,
	'K' = 13,
	'A' = 14
}

run_day7_part1 :: proc() {

	Player :: struct {
		hand: string,
		bid: int
	}

	Type :: enum {
		HighCard,
		OnePair,
		TwoPair,
		ThreeOfAKind,
		FullHouse,
		FourOfAKind,
		FiveOfAKind,
	}

	get_type :: proc(hand: string) -> (type: Type) {

		label_to_count: map[rune]int
		defer delete(label_to_count)

		// Initialize map with zeros
		for label in hand {
			label_to_count[label] = 0
		}

		for label in hand {
			label_to_count[label] += 1
		}

		pair_count := 0
		triplet_count := 0
		quartet_count := 0
		quintet_count := 0

		for label in label_to_count {
			count := label_to_count[label]
			if count == 5 {
				quintet_count += 1
			}
			else if count == 4 {
				quartet_count += 1
			}
			else if count == 3 {
				triplet_count += 1
			}
			else if count == 2 {
				pair_count += 1
			}
		}

		if quintet_count == 1 {
			type = .FiveOfAKind
		}
		else if quartet_count == 1 {
			type = .FourOfAKind
		}
		else if triplet_count == 1 && pair_count == 1 {
			type = .FullHouse
		}
		else if triplet_count == 1 && pair_count == 0 {
			type = .ThreeOfAKind
		}
		else if pair_count == 2 {
			type = .TwoPair
		}
		else if pair_count == 1 {
			type = .OnePair
		}
		else {
			type = .HighCard
		}

		return type
	}

	// returns true for less than and false for greater than
	compare :: proc(hand1: string, hand2: string) -> (less_than: bool) {

		assert(len(hand1) == len(hand2))

		// Shouldn't happen I think
		if hand1 == hand2 {
			return less_than
		}

		hand1_type := get_type(hand1)
		hand2_type := get_type(hand2)

		if hand1_type == hand2_type {

			for i in 0..<len(hand1) {
				strength1 := label_to_strength[hand1[i]]
				strength2 := label_to_strength[hand2[i]]

				if strength1 == strength2 {
					continue
				}
				else if strength1 < strength2 {
					less_than = true
					break
				}
				else {
					less_than = false
					break
				}
			}
		}
		else if hand1_type < hand2_type {
			less_than = true
		}
		else {
			less_than = false
		}

		return less_than

	}

	insertion_sort :: proc(sorted_players: ^[dynamic]Player, player: Player) {

		index := len(sorted_players)

		for sorted_player, i in sorted_players {

			less_than := compare(player.hand, sorted_player.hand)

			if less_than {
				index = i
				break
			}
		}

		inject_at(sorted_players, index, player) 
		fmt.println(player.hand, "inserted at", index)
	}

	// Sorts weakest to highest rank
	sort :: proc(players: ^[dynamic]Player) {

		sorted_players: [dynamic]Player
		defer delete(sorted_players)

		for player in players^ {
			insertion_sort(&sorted_players, player)
		}

		clear(players)
		append(players, ..sorted_players[:])
	}

	filepath := "7_input.txt"
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	players: [dynamic]Player
	defer delete(players)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {

		line_parts := strings.fields(line)
		assert(len(line_parts) == 2)
		hand := line_parts[0]
		bid := strconv.atoi(line_parts[1])
		append(&players, Player{hand, bid})
	}

	sort(&players)

	total_winnings := 0

	fmt.println()
	for player, i in players {
		rank := i + 1
		type := get_type(player.hand)
		fmt.println(player.hand, type)
		total_winnings += rank * player.bid
	}

	fmt.println()
	fmt.println(total_winnings)

}
