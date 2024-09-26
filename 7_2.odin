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
label_to_strength := map[u8]int{
	'J' = 1, // J is now the weakest
	'2' = 2,
	'3' = 3,
	'4' = 4,
	'5' = 5,
	'6' = 6,
	'7' = 7,
	'8' = 8,
	'9' = 9,
	'T' = 10,
	'Q' = 12,
	'K' = 13,
	'A' = 14
}

///////////////////////////////////////////////////////////////////////
// Types
///////////////////////////////////////////////////////////////////////

@(private="file")
Type :: enum {
	HighCard,
	OnePair,
	TwoPair,
	ThreeOfAKind,
	FullHouse,
	FourOfAKind,
	FiveOfAKind,
}

@(private="file")
Player :: struct {
	hand: string,
	bid: int
}

///////////////////////////////////////////////////////////////////////
// Procedures
///////////////////////////////////////////////////////////////////////

@(private="file")
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

	joker_label := 'J'
	joker_count := label_to_count[joker_label] or_else 0

	for label in label_to_count {
		count := label_to_count[label]
		if label != joker_label {
			count += joker_count
		}

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
	
	assert(quintet_count <= 1)
	assert(quartet_count <= 2)
	assert(triplet_count <= 3)
	assert(pair_count <= 4)

	if quintet_count == 1 {
		type = .FiveOfAKind
	}
	else if quartet_count >= 1 {
		type = .FourOfAKind
	}
	else if triplet_count == 2 || (triplet_count == 1 && pair_count == 1) {
		type = .FullHouse
	}
	else if triplet_count == 1 || triplet_count == 3 {
		type = .ThreeOfAKind
	}
	else if pair_count >= 2 && !strings.contains(hand, "J") {
		type = .TwoPair
	}
	else if pair_count >= 1 {
		type = .OnePair
	}
	else {
		type = .HighCard
	}

	return type
}

@test
test_get_type :: proc(t: ^testing.T) {
	
	testing.expect_value(t, get_type("AAAAA"), Type.FiveOfAKind)
	testing.expect_value(t, get_type("AAAAJ"), Type.FiveOfAKind)
	testing.expect_value(t, get_type("AAAJJ"), Type.FiveOfAKind)
	testing.expect_value(t, get_type("AAJJJ"), Type.FiveOfAKind)
	testing.expect_value(t, get_type("AJJJJ"), Type.FiveOfAKind)
	testing.expect_value(t, get_type("JJJJJ"), Type.FiveOfAKind)

	testing.expect_value(t, get_type("AAAAB"), Type.FourOfAKind)
	testing.expect_value(t, get_type("AAAJB"), Type.FourOfAKind)
	testing.expect_value(t, get_type("AAJJB"), Type.FourOfAKind)
	testing.expect_value(t, get_type("AJJJB"), Type.FourOfAKind)

	testing.expect_value(t, get_type("AABBB"), Type.FullHouse)
	testing.expect_value(t, get_type("AAJBB"), Type.FullHouse)

	testing.expect_value(t, get_type("AJJCB"), Type.ThreeOfAKind)
	testing.expect_value(t, get_type("AJACB"), Type.ThreeOfAKind)
	testing.expect_value(t, get_type("AAACB"), Type.ThreeOfAKind)

	testing.expect_value(t, get_type("AABBC"), Type.TwoPair)

	testing.expect_value(t, get_type("ABCDD"), Type.OnePair)
	testing.expect_value(t, get_type("ABCDJ"), Type.OnePair)

	testing.expect_value(t, get_type("ABCDE"), Type.HighCard)

}

// returns true for less than and false for greater than
@(private="file")
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

@(private="file")
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
	// fmt.println(player.hand, "inserted at", index)
}

// Sorts weakest to highest rank
@(private="file")
sort :: proc(players: ^[dynamic]Player) {

	sorted_players: [dynamic]Player
	defer delete(sorted_players)

	for player in players^ {
		insertion_sort(&sorted_players, player)
	}

	clear(players)
	append(players, ..sorted_players[:])
}

///////////////////////////////////////////////////////////////////////
// Main
///////////////////////////////////////////////////////////////////////

run_day7_part2 :: proc() {

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
		fmt.println(player.hand, player.bid, type)
		total_winnings += rank * player.bid
	}

	fmt.println()
	fmt.println(total_winnings)

}
