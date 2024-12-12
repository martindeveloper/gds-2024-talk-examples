package main

import "core:fmt"

Entity_Physics_Channel :: enum {
	None,
	Static,
	Dynamic,
}

Entity :: struct {
	name:            string `fmt:"s"`, // field tag example - `fmt:"s"` is a tag that tells the fmt package to print the field as a string
	physics_channel: Entity_Physics_Channel,
}

Entity_Extras :: struct {} // Add extra fields here

NonPlayableCharacter :: struct {
	using entity: Entity,
	using extras: Entity_Extras,
	health:       u32,
}

EnemyNPC :: struct {
	using npc: NonPlayableCharacter,
	damage:    u32,
}

entity_debug_print :: proc(entity: Entity) {
	fmt.printfln("Entity: %v", entity.name)
	fmt.printfln("Entity Physics Channel: %v", entity.physics_channel)
}

main :: proc() {
	enemy: EnemyNPC = EnemyNPC {
		name            = "Goblin",
		physics_channel = .Dynamic,
		health          = 100,
		damage          = 10,
	}

	// This is possible due subtype polymorphism using the `using` keyword
	entity_debug_print(enemy)

	// Print the enemy's information
	fmt.printfln("Enemy: %v", enemy.npc.entity.name)
	fmt.printfln("Physics Channel: %v", enemy.npc.entity.physics_channel)
	fmt.printfln("Health: %v", enemy.npc.health)
	fmt.printfln("Damage: %v", enemy.damage)

	// or print without naming the fields
	fmt.printfln("Enemy: %v", enemy.name)
	fmt.printfln("Physics Channel: %v", enemy.physics_channel)
	fmt.printfln("Health: %v", enemy.health)
	fmt.printfln("Damage: %v", enemy.damage)
}
