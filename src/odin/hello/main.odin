package main

import "core:fmt"
import "core:strings"

printClosingMessage :: proc() {
	fmt.println("\n...enjoy this amazing conference!")
}

main :: proc() {
	defer printClosingMessage()

	// Print the greeting message. If an error occurs, propagate it.
	fmt.printfln("Hello, %s!", "Game Developers Session")

	// Declare an optional year variable and assign it to nil.
	year_maybe: Maybe(u32) = nil

	// Use the optional value or default to 2024.
	year_current := year_maybe.? or_else 2024

	// Print the year message. If an error occurs, propagate it.
	fmt.printfln("Are you ready for %d year?", year_current)
}
